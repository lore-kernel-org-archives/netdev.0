From: walter harms <wharms@bfs.de>
Subject: Re: [PATCH] hdlcdrv: fix divide error bug if bitrate is 0
Date: Wed, 17 May 2017 18:08:11 +0200
Message-ID: <591C756B.8060109@bfs.de>
References: <20170517123549.22659-1-firogm@gmail.com> <591C493B.6060908@bfs.de> <20170517134246.GA24874@snow>
Reply-To: wharms@bfs.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-hams@vger.kernel.org, netdev@vger.kernel.org
To: Firo Yang <firogm@gmail.com>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20170517134246.GA24874@snow>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Am 17.05.2017 15:42, schrieb Firo Yang:
> On Wed, May 17, 2017 at 02:59:39PM +0200, walter harms wrote:
>>
>>
>> Am 17.05.2017 14:35, schrieb Firo Yang:
>>> The divisor s->par.bitrate will always be 0 until initialized by
>>> ndo_open() and hdlcdrv_open().
>>>
>>> In order to fix this divide zero error, check whether the netdevice
>>> was opened by ndo_open() before performing divide.
>>>
>>> Reported-by: Dmitry Vyukov <dvyukov@google.com>
>>> Signed-off-by: Firo Yang <firogm@gmail.com>
>>> ---
>>>  drivers/net/hamradio/hdlcdrv.c | 2 +-
>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> diff --git a/drivers/net/hamradio/hdlcdrv.c b/drivers/net/hamradio/hdlcdrv.c
>>> index 8c3633c..3c783fd 100644
>>> --- a/drivers/net/hamradio/hdlcdrv.c
>>> +++ b/drivers/net/hamradio/hdlcdrv.c
>>> @@ -574,7 +574,7 @@ static int hdlcdrv_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
>>>  		break;		
>>>  
>>>  	case HDLCDRVCTL_CALIBRATE:
>>> -		if(!capable(CAP_SYS_RAWIO))
>>> +		if (!capable(CAP_SYS_RAWIO) || !netif_running(dev))
>>>  			return -EPERM;
>>>  		if (bi.data.calibrate > INT_MAX / s->par.bitrate)
>>>  			return -EINVAL;
>>
>> I would still check for s->par.bitrate > 0 later changes may affect the setting of it
>> and it is much more obvious.
> 
> I think 0 is not valid value for bitrate, so we should check it in
> other places, like what ser12_open() did:
> 429         if (bc->baud < 300 || bc->baud > 4800) {
> 430                 printk(KERN_INFO "baycom_ser_fdx: invalid baudrate "
> 431                                 "(300...4800)\n");
> 432                 return -EINVAL;
> 433         }
> ...
> 440         bc->hdrv.par.bitrate = bc->baud;


I do not want to say you change is not valid but i have learned that it is better to
have an obvious check that to rely on hidden knowledge.


> 
>>
>> Also perhaps !netif_running(dev) should better return ENODEV.
> 
> However, the 'dev' truly exists in this circumstance.
> 

yes and i do not feel good with that but "no permission" will lead
any enduser into a search for user rights.



re,
 wh


> Thanks,
> Firo
> 
>>
>>
>> just my 2 cents,
>> re,
>> wh
>>
