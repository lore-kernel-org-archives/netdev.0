From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: [PATCH v2 1/1] net: fec: ptp: avoid register access when ipg
 clock is disabled
Date: Thu, 14 Aug 2014 01:28:28 +0000
Message-ID: <4dcf48cd1c11473c82fcec0c8963ece2@BLUPR03MB373.namprd03.prod.outlook.com>
References: <1407905705-27984-1-git-send-email-b38611@freescale.com>
 <1407905705-27984-2-git-send-email-b38611@freescale.com>
 <20140813211941.GB4840@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2lp0203.outbound.protection.outlook.com ([207.46.163.203]:49297
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751866AbaHNB2t convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2014 21:28:49 -0400
In-Reply-To: <20140813211941.GB4840@netboy>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com> Data: Thursday, August 14, 2014 5:20 AM
>To: Duan Fugang-B38611
>Cc: shawn.guo@linaro.org; davem@davemloft.net; netdev@vger.kernel.org
>Subject: Re: [PATCH v2 1/1] net: fec: ptp: avoid register access when ipg
>clock is disabled
>
>On Wed, Aug 13, 2014 at 12:55:05PM +0800, Fugang Duan wrote:
>
>> diff --git a/drivers/net/ethernet/freescale/fec_main.c
>> b/drivers/net/ethernet/freescale/fec_main.c
>> index 66fe1f6..8befa2c 100644
>> --- a/drivers/net/ethernet/freescale/fec_main.c
>> +++ b/drivers/net/ethernet/freescale/fec_main.c
>> @@ -2198,6 +2198,8 @@ fec_enet_open(struct net_device *ndev)
>>  	napi_enable(&fep->napi);
>>  	phy_start(fep->phy_dev);
>>  	netif_start_queue(ndev);
>> +	if (fep->hwts_tx_en)
>> +		schedule_delayed_work(&fep->time_keep, HZ);
>>  	return 0;
>>  }
>>
>> @@ -2206,6 +2208,9 @@ fec_enet_close(struct net_device *ndev)  {
>>  	struct fec_enet_private *fep = netdev_priv(ndev);
>>
>> +	if (fep->hwts_tx_en)
>> +		cancel_delayed_work_sync(&fep->time_keep);
>
>You make the clock logic depend on whether time stamping is enabled or not.
>Why do you do that?
>
>The clock should keep ticking, even if time stamping is disabled.
>
If the ethx close, ptp stack cannot run normally, stack stop send sync message with master,
So we also cancel the delayed work.

In addition, ethx interface close also gate ipg clock, if there have register access hw will hang.
So it is necessary to cancel the delayed work.

>Thanks,
>Richard
