From: Richard Weinberger <richard@nod.at>
Subject: Re: [PATCH] hyperv: Add netpoll support
Date: Tue, 08 Jul 2014 20:40:26 +0200
Message-ID: <53BC3B1A.4000009@nod.at>
References: <1404811947-5174-1-git-send-email-richard@nod.at>
 <6869a7dec43b4ba6b38692874f67279a@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Haiyang Zhang <haiyangz@microsoft.com>, KY Srinivasan <kys@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <6869a7dec43b4ba6b38692874f67279a@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
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

Am 08.07.2014 19:55, schrieb Haiyang Zhang:
> 
> 
>> -----Original Message-----
>> From: Richard Weinberger [mailto:richard@nod.at]
>> Sent: Tuesday, July 8, 2014 5:32 AM
>> To: KY Srinivasan; Haiyang Zhang
>> Cc: devel@linuxdriverproject.org; netdev@vger.kernel.org; linux-
>> kernel@vger.kernel.org; Richard Weinberger
>> Subject: [PATCH] hyperv: Add netpoll support
>>
>> In order to have at least a netconsole to debug kernel issues on
>> Windows Azure this patch implements netpoll support.
>> Sending packets is easy, netvsc_start_xmit() does already everything
>> needed.
>> To receive we need to trigger the channel callback which is usally
>> called via tasklet_schedule().
>>
>> Signed-off-by: Richard Weinberger <richard@nod.at>
>> ---
>>  drivers/net/hyperv/netvsc_drv.c | 14 ++++++++++++++
>>  1 file changed, 14 insertions(+)
>>
>> diff --git a/drivers/net/hyperv/netvsc_drv.c
>> b/drivers/net/hyperv/netvsc_drv.c
>> index 4fd71b7..367b71e 100644
>> --- a/drivers/net/hyperv/netvsc_drv.c
>> +++ b/drivers/net/hyperv/netvsc_drv.c
>> @@ -736,6 +736,17 @@ static int netvsc_set_mac_addr(struct net_device
>> *ndev, void *p)
>>  	return err;
>>  }
>>
>> +#ifdef CONFIG_NET_POLL_CONTROLLER
>> +static void netvsc_poll_controller(struct net_device *net)
>> +{
>> +	struct net_device_context *net_device_ctx = netdev_priv(net);
>> +	struct hv_device *dev = net_device_ctx->device_ctx;
>> +
>> +	local_bh_disable();
>> +	netvsc_channel_cb(dev->channel);
> 
> This can only poll the primary channel not the sub channels.

Sub channels in terms of one channel per VCPU as KY said?

*confused*,
//richard
