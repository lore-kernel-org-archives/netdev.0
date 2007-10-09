From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/8][BNX2X] resubmit as attachments: add bnx2x to
 Kconfig and Makefile
Date: Mon, 08 Oct 2007 21:29:31 -0700 (PDT)
Message-ID: <20071008.212931.82537619.davem@davemloft.net>
References: <470A5795.2000809@broadcom.com>
	<20071008.174603.55855492.davem@davemloft.net>
	<470AFFE3.100@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, mchan@broadcom.com
To: eliezert@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52956
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750841AbXJIE3c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 00:29:32 -0400
In-Reply-To: <470AFFE3.100@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Eliezer Tamir" <eliezert@broadcom.com>
Date: Tue, 09 Oct 2007 06:13:23 +0200

> Due to the size of the patch I can not post it to the list.

Understood

> Here is an FTP link.
> ftp://Net_sys_anon@ftp1.broadcom.com/bnx2x-0.40.10-net-2.6.24-one.patch.txt
> 
> Or if you prefer, I can post it gzipped.

I took a look at what takes up so much space and it's the firmware and
this register init stuff.

The firmware is unavoidable, but wrt. the register init tables there
appears to be a ton of superfluous information in that header file.

It seem extreme overkill and I would guess it exists purely to
simplify your in-house chip validation.  I would really wish you
wouldn't do this as these tables take up unswappable kernel memory.

No other driver goes about initializing the chip registers using
tables like this.  Many of them are sequences of nothing but zeros or
the same value repeated over and over!  The non-zero values that are
specific are "magic constants" with no macros to describe up the
meaning of the bits being set in these registers.

Huge functions like bnx2x_idle_chk() that just validate register
values with hundreds of lines of C code are not appropriate for
submission into a Linux kernel network driver.  Again, this looks
like code that assists you with in-house chip validation.

I'm open to putting self tests into the driver, but this adds so much
bloat it really takes things beyond reasonable.

Please remove this self-test code and compress the register
initialization information, preferrably into foo_hw_init() C functions
as is done traditionally in drivers.  It will take up less space,
remove the magic values, and make the hardware easier to understand
for other developers.

This should get the driver under the posting limit of 400K, which to
be honest no driver's should be larger than.  Unfortunately that
firmware file is 350K so you won't have much left to work with :-)

What we could do is post the driver without the firmware, so that
people can review the actual C-code by just replying to this posting
and it won't go over the posting size limit.

Thanks!
