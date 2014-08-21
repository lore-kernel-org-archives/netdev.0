From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: [PATCH v4 1/1] net: fec: ptp: avoid register access when ipg
 clock is disabled
Date: Thu, 21 Aug 2014 09:24:12 +0000
Message-ID: <9d371ae6598c4b72838ec72be63cb554@BLUPR03MB373.namprd03.prod.outlook.com>
References: <1408418453-28012-1-git-send-email-b38611@freescale.com>
 <1408418453-28012-2-git-send-email-b38611@freescale.com>
 <20140821070241.GB6231@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1blp0184.outbound.protection.outlook.com ([207.46.163.184]:39462
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753468AbaHUJYO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2014 05:24:14 -0400
In-Reply-To: <20140821070241.GB6231@netboy>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com> Sent: Thursday, August 21, 2014 3:03 PM
>To: Duan Fugang-B38611
>Cc: davem@davemloft.net; netdev@vger.kernel.org; shawn.guo@linaro.org
>Subject: Re: [PATCH v4 1/1] net: fec: ptp: avoid register access when ipg
>clock is disabled
>
>On Tue, Aug 19, 2014 at 11:20:53AM +0800, Fugang Duan wrote:
>> The current kernel hang on i.MX6SX with rootfs mount from MMC.
>> The root cause is ptp rise up period timer to access enet register
>
>s/ptp rise up period/that ptp uses a periodic/
>
>> even if ipg clock is disabled.
>
>...
>
>> diff --git a/drivers/net/ethernet/freescale/fec_ptp.c
>b/drivers/net/ethernet/freescale/fec_ptp.c
>> index 82386b2..6d65555 100644
>> --- a/drivers/net/ethernet/freescale/fec_ptp.c
>> +++ b/drivers/net/ethernet/freescale/fec_ptp.c
>> @@ -245,12 +245,18 @@ static int fec_ptp_settime(struct ptp_clock_info
>*ptp,
>>  	u64 ns;
>>  	unsigned long flags;
>>
>> +	mutex_lock(&fep->ptp_clk_mutex);
>> +	/* Check the ptp clock */
>> +	if (!fep->ptp_clk_on)
>> +		return -EINVAL;
>
>You are still holding the mutex here.
>
>> +
>>  	ns = ts->tv_sec * 1000000000ULL;
>>  	ns += ts->tv_nsec;
>>
>>  	spin_lock_irqsave(&fep->tmreg_lock, flags);
>>  	timecounter_init(&fep->tc, &fep->cc, ns);
>>  	spin_unlock_irqrestore(&fep->tmreg_lock, flags);
>> +	mutex_unlock(&fep->ptp_clk_mutex);
>>  	return 0;
>>  }
>
Thanks for your review, I will send the next.

Thanks,
Andy
