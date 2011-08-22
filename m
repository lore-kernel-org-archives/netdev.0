From: walter harms <wharms-fPG8STNUNVg@public.gmane.org>
Subject: Re: [PATCH 4/4] drivers/net/wireless/mwifiex/scan.c: test the just-initialized
 value
Date: Mon, 22 Aug 2011 21:09:26 +0200
Message-ID: <4E52A966.3090502@bfs.de>
References: <1314021636-11528-4-git-send-email-julia@diku.dk> <4E52638C.8080407@inria.fr> <Pine.LNX.4.64.1108221615450.10948@ask.diku.dk> <477F20668A386D41ADCC57781B1F70430802DD7B7E@SC-VEXCH1.marvell.com>
Reply-To: wharms-fPG8STNUNVg@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>,
	Pierre Louis Aublin <pierre-louis.aublin-MZpvjPyXg2s@public.gmane.org>,
	"kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Bing Zhao <bzhao-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <477F20668A386D41ADCC57781B1F70430802DD7B7E-r8ILAu4/owuHXkj8w7BxOhL4W9x8LtSr@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



Am 22.08.2011 21:02, schrieb Bing Zhao:
> Hi Julia,
> 
> Thanks for the patch.
> 
>> -----Original Message-----
>> From: Julia Lawall [mailto:julia-dAYI7NvHqcQ@public.gmane.org]
>> Sent: Monday, August 22, 2011 7:16 AM
>> To: Pierre Louis Aublin
>> Cc: Bing Zhao; kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; John W. Linville; linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org;
>> netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> Subject: [PATCH 4/4] drivers/net/wireless/mwifiex/scan.c: test the just-initialized value
>>
>> From: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>
>>
>> Test the just-initialized value rather than some other one.
>>
>> The semantic match that finds this problem is as follows:
>> (http://coccinelle.lip6.fr/)
>>
>> // <smpl>
>> @r@
>> identifier x,y,f!={PTR_ERR,ERR_PTR,ERR_CAST};
>> statement S;
>> @@
>>
>> x = f(...);
>> (
>> if (\(x == NULL\|IS_ERR(x)\)) S
>> |
>> *if (\(y == NULL\|IS_ERR(y)\))
>>  { ... when != x
>>    return ...; }
>> )
>> // </smpl>
>>
>> Signed-off-by: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>
> 
> Acked-by: Bing Zhao <bzhao-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>
> 
> 
> Thanks,
> Bing
> 
>>
>> ---
>>  drivers/net/wireless/mwifiex/scan.c |    4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/wireless/mwifiex/scan.c b/drivers/net/wireless/mwifiex/scan.c
>> index b28241c..37ca2f9 100644
>> --- a/drivers/net/wireless/mwifiex/scan.c
>> +++ b/drivers/net/wireless/mwifiex/scan.c
>> @@ -1480,8 +1480,8 @@ mwifiex_update_curr_bss_params(struct mwifiex_private *priv,
>>  		return -ENOMEM;
>>  	}
>>  	beacon_ie = kzalloc(ie_len, GFP_KERNEL);
>> -	if (!bss_desc) {
>> -		dev_err(priv->adapter->dev, " failed to alloc bss_desc\n");
>> +	if (!beacon_ie) {
>> +		dev_err(priv->adapter->dev, " failed to alloc beacon_ie\n");
>>  		return -ENOMEM;
>>  	}
>>  	memcpy(beacon_ie, ie_buf, ie_len);
> --


this looks like a case for kmemdup()

just my 2 cents,

re,
 wh


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
