From: Robert MARKLUND <robert.marklund@stericsson.com>
Subject: RE: net/smsc911x: problems after commit 3ac3546e [Always wait for
 the chip to be ready]
Date: Tue, 13 Nov 2012 09:20:33 +0100
Message-ID: <2B1D156D95AE9B4EAD379CB9E465FE73272C64B600@EXDCVYMBSTM005.EQ1STM.local>
References: <20121106.123623.676046673605774326.davem@davemloft.net>
	<20121108.015754.967579869456342727.davem@davemloft.net>
	<20121112100445.GA12511@patelk@broadcom.com>
 <20121112.144027.1074374601388950128.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "steve@shawell.net" <steve@shawell.net>,
	"linus.walleij@linaro.org" <linus.walleij@linaro.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	"kamlakant.patel@broadcom.com" <kamlakant.patel@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:57801 "EHLO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753496Ab2KMIUp convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2012 03:20:45 -0500
In-Reply-To: <20121112.144027.1074374601388950128.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't forget to push so that the HW guys update the datasheet as Linus W mentioned.
BR
Robert

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: den 12 november 2012 20:40
> To: kamlakant.patel@broadcom.com
> Cc: steve@shawell.net; linus.walleij@linaro.org; Robert MARKLUND; netdev@vger.kernel.org
> Subject: Re: net/smsc911x: problems after commit 3ac3546e [Always wait for the chip to be ready]
> 
> From: "Kamlakant Patel" <kamlakant.patel@broadcom.com>
> Date: Mon, 12 Nov 2012 15:34:46 +0530
> 
> > On Thu, Nov 08, 2012 at 01:57:54AM -0500, David Miller wrote:
> >> From: "Kamlakant Patel" <kamlakant.patel@broadcom.com>
> >> Date: Thu, 8 Nov 2012 12:16:28 +0530
> >>
> >> > smsc driver is disabled in our bootloader and it is not changing the
> >> > state of the smsc registers at any stage, so it is not a bootloader
> >> > issue.
> >>
> >> What puts that chip into a non-default byte swapping mode then?
> >
> > This is a property of the XLP GBU (IO bus flash like devices). A 32-bit
> > read/write will be split into two 16-bit operations, and when the XLP is
> > in big-endian mode, we get the lower 16-bit ends up in bits 31-16 and the
> > upper 16-bit in bits 15-0.
> >
> > The code before commit 3ac3546e worked because the driver saw that the registers
> > are word swapped (not byte swapped) and programmed the WORD_SWAP register
> > first (before any other register operations).
> 
> Ok, fair enough.   Someone can resubmit the patch, and I'll apply it,
> but I still very much dislike this situation.
> 
> Please make sure there is a very verbose comment added to the code,
> and a similarly verbose commit message for the patch explaining
> exactly how the chip gets into this state and why we have to solve
> the problem this way.
> 
> Thanks.
