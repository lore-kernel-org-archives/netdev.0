From: zhangfei <zhangfei.gao@linaro.org>
Subject: Re: [PATCH 3/3] net: hisilicon: new hip04 ethernet driver
Date: Fri, 18 Apr 2014 21:17:52 +0800
Message-ID: <53512600.6020902@linaro.org>
References: <1396672506-9296-1-git-send-email-zhangfei.gao@linaro.org>	<1396672506-9296-4-git-send-email-zhangfei.gao@linaro.org> <20140407.145356.928382660541891827.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux@arm.linux.org.uk, arnd@arndb.de, f.fainelli@gmail.com,
	sergei.shtylyov@cogentembedded.com, mark.rutland@arm.com,
	David.Laight@ACULAB.COM, eric.dumazet@gmail.com,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:52884 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754369AbaDRNSC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2014 09:18:02 -0400
Received: by mail-pd0-f179.google.com with SMTP id w10so1433627pde.24
        for <netdev@vger.kernel.org>; Fri, 18 Apr 2014 06:18:02 -0700 (PDT)
In-Reply-To: <20140407.145356.928382660541891827.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear David

On 04/08/2014 02:53 AM, David Miller wrote:

>> +static void hip04_tx_reclaim(struct net_device *ndev, bool force)
>   ...
>> +static void hip04_xmit_timer(unsigned long data)
>> +{
>> +	struct net_device *ndev = (void *) data;
>> +
>> +	hip04_tx_reclaim(ndev, false);
>> +}
>   ...
>> +	mod_timer(&priv->txtimer, jiffies + RECLAIM_PERIOD);
>
> And this is where I stop reading your driver, I've stated already that this
> kind of reclaim scheme is unacceptable.
>
> The kernel timers lack the granularity necessary to service TX reclaim
> with a reasonable amount of latency.
>
> You must use some kind of hardware notification of TX slots becomming
> available, I find it totally impossible that a modern ethernet controller
> was created without a TX done interrupt.
>

There is no tx_done interrupt, we may need some workaround.

Is it acceptable to use poll to reclaim the xmitted buffer.
And in the xmit calling napi_schedule.

Thanks
