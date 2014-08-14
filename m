From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v2 1/1] net: fec: ptp: avoid register access when ipg
 clock is disabled
Date: Thu, 14 Aug 2014 16:33:51 +0200
Message-ID: <20140814143351.GA29615@netboy>
References: <1407905705-27984-1-git-send-email-b38611@freescale.com>
 <1407905705-27984-2-git-send-email-b38611@freescale.com>
 <20140813211941.GB4840@netboy>
 <4dcf48cd1c11473c82fcec0c8963ece2@BLUPR03MB373.namprd03.prod.outlook.com>
 <20140814081036.GB7555@netboy>
 <e84f5b51501e4add8cf08819c64ef554@BLUPR03MB373.namprd03.prod.outlook.com>
 <20140814084251.GC7555@netboy>
 <4977c4d325c949019549211d74c6982d@BLUPR03MB373.namprd03.prod.outlook.com>
 <20140814091259.GA11727@netboy>
 <4f93901dbe7a4746aacc795ae825ee60@BLUPR03MB373.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:46101 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755016AbaHNOd7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 10:33:59 -0400
Received: by mail-wi0-f179.google.com with SMTP id f8so2402796wiw.6
        for <netdev@vger.kernel.org>; Thu, 14 Aug 2014 07:33:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4f93901dbe7a4746aacc795ae825ee60@BLUPR03MB373.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 14, 2014 at 09:26:45AM +0000, fugang.duan@freescale.com wrote:
> When ethx disable, all clocks are disabled. For gettime(), your mean that we check clock is on or not,
> If clock is disabled, return an error in .fec_ptp_gettime() ?

Yes.

> How did it in the delayed work ?

The work must run whenever the physical clock is runnning.

This is COMPLETELY INDEPENDENT from time stamping.

If your patch has anything with "fep->hwts_tx_en", then it is wrong.

> Thanks for your review, I am confused by your suggestion.

Just start and stop the work queue when you start and stop the
physical clock.

Is it clear now?

Thanks,
Richard
