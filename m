From: Richard Weinberger <richard@nod.at>
Subject: Re: [PATCH v2] hyperv: Add netpoll support
Date: Wed, 09 Jul 2014 16:24:50 +0200
Message-ID: <53BD50B2.8050007@nod.at>
References: <1404892702-11094-1-git-send-email-richard@nod.at>
 <53BD4DFD.6070805@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, romieu@fr.zoreil.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
 kys@microsoft.com, haiyangz@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <53BD4DFD.6070805@cogentembedded.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

Am 09.07.2014 16:13, schrieb Sergei Shtylyov:
> Hello.
> 
> On 07/09/2014 11:58 AM, Richard Weinberger wrote:
> 
>> In order to have at least a netconsole to debug kernel issues on
>> Windows Azure this patch implements netpoll support.
>> Sending packets is easy, netvsc_start_xmit() does already everything
>> needed.
> 
>> Signed-off-by: Richard Weinberger <richard@nod.at>
>> ---
>>   drivers/net/hyperv/netvsc_drv.c | 11 +++++++++++
>>   1 file changed, 11 insertions(+)
> 
>> diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
>> index 4fd71b7..45218d5 100644
>> --- a/drivers/net/hyperv/netvsc_drv.c
>> +++ b/drivers/net/hyperv/netvsc_drv.c
>> @@ -736,6 +736,14 @@ static int netvsc_set_mac_addr(struct net_device *ndev, void *p)
>>       return err;
>>   }
>>
>> +#ifdef CONFIG_NET_POLL_CONTROLLER
>> +static void netvsc_poll_controller(struct net_device *net)
>> +{
>> +    /* As netvsc_start_xmit() works synchronous we don't have to
>> +       trigger anything here. */
> 
>    The multi-line comment style in the networking code is this:
> 
> /* bla
>  * bla
>  */
> 
>> +    return;
> 
>    Not needed.
> 
>> +}
>> +#endif
> [...]

-ETOOMANYCODINGSTYLES :)

Thanks,
//richard
