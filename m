From: "Hennerich, Michael" <Michael.Hennerich@analog.com>
Subject: RE: [PATCH] netdev: enc28j60: use IRQF_TRIGGER_FALLING for IRQ by default
Date: Wed, 27 May 2009 16:18:14 +0100
Message-ID: <8A42379416420646B9BFAC9682273B6D0B37619F@limkexm3.ad.analog.com>
References: <1243333007-25645-1-git-send-email-vapier@gentoo.org> <20090526110614.GA1987@jasper.tkos.co.il> <200905260424.17654.david-b@pacbell.net> <200905261253.07364.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Baruch Siach" <baruch@tkos.co.il>, <netdev@vger.kernel.org>,
	"Bryan Wu" <cooloney@kernel.org>
To: "Mike Frysinger" <vapier@gentoo.org>,
	"David Brownell" <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail11.analog.com ([137.71.25.57]:22174 "EHLO
	nwd2mail11.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751322AbZE0PWK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 11:22:10 -0400
Content-Class: urn:content-classes:message
In-Reply-To: <200905261253.07364.vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From: Mike Frysinger [mailto:vapier@gentoo.org]
>On Tuesday 26 May 2009 07:24:17 David Brownell wrote:
>> On Tuesday 26 May 2009, Baruch Siach wrote:
>> > On Tue, May 26, 2009 at 06:16:47AM -0400, Mike Frysinger wrote:
>> > > From: Michael Hennerich <michael.hennerich@analog.com>
>> > >
>> > > Rather than have the default IRQ flags not be usable, use the
logical
>> > > settings which match the hardware.  Since the part is /INT, it
makes
>> > > sense to have it default to a falling trigger.  If a board truly
needs
>> > > something different, it still can tweak the defaults in its own
board
>> > > file.
>> >
>> > You revert David Brownell's commit here
>> > (c7b7b042068cd12b8b155722d24686f70b88ced1). Added to CC.
>>
>> Right ... the appended patch will *undo* the setting
>> established in the board init code via set_irq_type().
>>
>> Moreover, it completely prevents working on systems which
>> only support "both edges" triggering.
>
>how can it provide breakage when people are forced to use
set_irq_type() ?

set_irq_type() is typically called before request_irq().
In case be give the IRQF_TRIGGER flag with request_irq() it will
overwrite the settings done by set_irq_type().

-Michael
>
>> So I'd NAK this, on the grounds that it causes severe
>> breakage.
>
>i see no consumers of this driver at all in mainline, so i dont think
it
>causes any in tree breakage at all
>-mike
