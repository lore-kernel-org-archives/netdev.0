From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] net: fec: ptp: avoid register access when ipg clock is
 disabled
Date: Mon, 21 Jul 2014 18:40:04 +0200
Message-ID: <20140721164004.GA13039@localhost.localdomain>
References: <1405910155-29760-1-git-send-email-b38611@freescale.com>
 <20140721040301.GA4035@localhost.localdomain>
 <08eaaff4b82b42538d6a0f4193ecb805@BLUPR03MB373.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:39041 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932412AbaGUQk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 12:40:28 -0400
Received: by mail-wi0-f171.google.com with SMTP id hi2so4474655wib.16
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2014 09:40:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <08eaaff4b82b42538d6a0f4193ecb805@BLUPR03MB373.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 21, 2014 at 10:46:31AM +0000, fugang.duan@freescale.com wrote:

> >> +	if (fep->bufdesc_ex && (fep->hwts_tx_en || fep->hwts_rx_en))
> >> +		fec_ptp_stop(ndev);
> >
> >So if user space turns time stamping off, then you keep running the timer.
> >That is wrong, isn't it?
> >
> If user close the ethx interface, or do suspend operation, fec driver will
> Close all clocks to save power, we also need to stop ptp, otherwise ptp timer
> Keep access register that cause system hang.
> 
> I don't think this is a good method, maybe I need some time to struct better solution.

What?

Look at the code that you wrote. You have:

	IF   x AND (fep->hwts_tx_en || fep->hwts_rx_en)
	THEN fec_ptp_stop;

So if the user clears 'hwts_tx_en' and 'hwts_rx_en' using the ioctl,
you don't stop the timer. But in order to fix the bug, you should stop
the timer in any case.

> >Why not use a work queue for this?
>
> There need one period timer to sync hw timer to avoid 32 bit hw counter overflow.

So why not use schedule_delayed_work?

Thanks,
Richard
