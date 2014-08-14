From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v2 1/1] net: fec: ptp: avoid register access when ipg
 clock is disabled
Date: Thu, 14 Aug 2014 10:42:51 +0200
Message-ID: <20140814084251.GC7555@netboy>
References: <1407905705-27984-1-git-send-email-b38611@freescale.com>
 <1407905705-27984-2-git-send-email-b38611@freescale.com>
 <20140813211941.GB4840@netboy>
 <4dcf48cd1c11473c82fcec0c8963ece2@BLUPR03MB373.namprd03.prod.outlook.com>
 <20140814081036.GB7555@netboy>
 <e84f5b51501e4add8cf08819c64ef554@BLUPR03MB373.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:32839 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752196AbaHNInF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 04:43:05 -0400
Received: by mail-wi0-f178.google.com with SMTP id hi2so1928224wib.5
        for <netdev@vger.kernel.org>; Thu, 14 Aug 2014 01:43:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <e84f5b51501e4add8cf08819c64ef554@BLUPR03MB373.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 14, 2014 at 08:24:39AM +0000, fugang.duan@freescale.com wrote:
> 1. HW ptp is one feature of FEC IP, when the ethx interface is closed, ptp slave cannot sync with master,
>    So the ptp timer is not accurate, of couse there have discontinuities in ptp clock.

No, it just becomes a free running clock.

This is no different than the Linux system clock. It keeps running,
even if ntpd is not.

> 2. When the ethx net interface is closed, FEC IP clocks are disabled, access ptp counter register causes
>    Hw hang.

Well, then, you need to return an error, don't you?

> 3. PTP is not separate HW IP, which is one hw feature of FEC IP, when the net interface is closed, user
>    Call clock_gettime() is not reasonable.

Yes, it is. See #1.

Thanks,
Richard
