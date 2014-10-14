From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] net: fec: ptp: fix convergence issue to support LinuxPTP
 stack
Date: Tue, 14 Oct 2014 20:49:52 +0200
Message-ID: <20141014184952.GC14216@localhost.localdomain>
References: <1413265187-5228-1-git-send-email-b38611@freescale.com>
 <20141014103610.GA4019@localhost.localdomain>
 <20141014.125239.1562178476120218308.davem@davemloft.net>
 <7e6db0b336a340bd80b62475fca284fc@BLUPR03MB486.namprd03.prod.outlook.com>
 <20141014183933.GA14216@localhost.localdomain>
 <6b1256b73b7a4f978573a77ec3e36831@BLUPR03MB486.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"fugang.duan@freescale.com" <fugang.duan@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>
To: "Frank.Li@freescale.com" <Frank.Li@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:59351 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754166AbaJNSt5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 14:49:57 -0400
Received: by mail-wi0-f176.google.com with SMTP id hi2so10998112wib.3
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2014 11:49:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <6b1256b73b7a4f978573a77ec3e36831@BLUPR03MB486.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 14, 2014 at 06:43:51PM +0000, Frank.Li@freescale.com wrote:
> Only MX6 SX. Only MX6 SX added FEC_QUIRK_BUG_CAPTURE.

But what about this comment:

+/* ENET Block Guide/ Chapter for the iMX6SLX (PELE) address one issue:
+ * Incorrect behavior for ENET_ATCR[Capture and Restart Bits]. These bits will
+ * always read a value zero. When these bits are set to 1'b1, these should hold
+ * value 1'b1 until the counter value is capture in the register clock domain.
+ */

It sounds like the bits are "sticky" until the counter value has been
latched. Therefore you need to check the bits before reading the
counter, but the code does not do this for the case of !SX.

Thanks,
Richard
