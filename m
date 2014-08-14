From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v2 1/1] net: fec: ptp: avoid register access when ipg
 clock is disabled
Date: Thu, 14 Aug 2014 10:10:36 +0200
Message-ID: <20140814081036.GB7555@netboy>
References: <1407905705-27984-1-git-send-email-b38611@freescale.com>
 <1407905705-27984-2-git-send-email-b38611@freescale.com>
 <20140813211941.GB4840@netboy>
 <4dcf48cd1c11473c82fcec0c8963ece2@BLUPR03MB373.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:54020 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751078AbaHNIKl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 04:10:41 -0400
Received: by mail-wi0-f171.google.com with SMTP id hi2so8512478wib.4
        for <netdev@vger.kernel.org>; Thu, 14 Aug 2014 01:10:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4dcf48cd1c11473c82fcec0c8963ece2@BLUPR03MB373.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 14, 2014 at 01:28:28AM +0000, fugang.duan@freescale.com wrote:
> If the ethx close, ptp stack cannot run normally, stack stop send sync message with master,

But this has no effect on whether transmit time stamps are enabled.

The timer work must run whenever the (physical) clock is
running. Otherwise you will have discontinuities in your PTP clock.
The kernel must always behave correctly, regardless of what user space
does.

When the user calls clock_gettime(), the result must always be
consistent. This has nothing to do with time stamping at all.

Thanks,
Richard
