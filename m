From: Jeff Garzik <jeff@garzik.org>
Subject: [RFT] e100 driver on ARM
Date: Mon, 04 Sep 2006 06:39:29 -0400
Message-ID: <44FC0261.6010807@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@osdl.org>,
	Russell King <rmk+lkml@arm.linux.org.uk>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:44269 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751383AbWIDKjd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2006 06:39:33 -0400
To: Netdev List <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

One of the last steps necessary to deprecate the eepro100 driver is to 
ensure that e100 works everywhere that eepro100 does.

The eepro100 removal has been blocked for almost a year by a vague 
suggestion from Russell that e100 doesn't work on ARM.  But he doesn't 
have that machine anymore.  So, we're stuck in limbo.

This is a call to anyone who can test an Intel 10/100 chip on the ARM 
platform, in an effort to see where we are.  I'm looking for answers to 
the following two questions:

1) Does e100 driver work on ARM?

2) If not, does the "e100-sbit" branch of 
git://git.kernel.org/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git 
work on ARM?

FWIW, the e100-sbit branch has been in Andrew Morton's -mm tree since 
Nov 2005.

Below is the commit message for the e100-sbit change, in case anyone is 
interested.  I'm also hoping that Intel will help solve this problem, 
but poking Intel hasn't produced very much :(

	Jeff


> commit 32c1459bb3814274b3c5e0c5ed4efc6c0aa89eb4
> Author: Scott Feldman <sfeldma@pobox.com>
> Date:   Wed Nov 9 02:18:52 2005 -0500
> 
>     [netdrvr e100] experiment with doing RX in a similar manner to eepro100
> 
>     I was going to say that eepro100's speedo_rx_link() does the same DMA
>     abuse as e100, but then I noticed one little detail: eepro100 sets  both
>     EL (end of list) and S (suspend) bits in the RFD as it chains it  to the
>     RFD list.  e100 was only setting the EL bit.  Hmmm, that's  interesting.
>     That means that if HW reads a RFD with the S-bit set,  it'll process
>     that RFD and then suspend the receive unit.  The  receive unit will
>     resume when SW clears the S-bit.  There is no need  for SW to restart
>     the receive unit.  Which means a lot of the receive  unit state tracking
>     code in the driver goes away.
> 
>     So here's a patch against 2.6.14.  (Sorry for inlining it; the mailer
>     I'm using now will mess with the word wrap).  I can't test this on
>     XScale (unless someone has an e100 module for Gumstix :) .  It should
>     be doing exactly what eepro100 does with RFDs.  I don't believe this
>     change will introduce a performance hit because the S-bit and EL-bit  go
>     hand-in-hand meaning if we're going to suspend because of the S- bit,
>     we're on the last resource anyway, so we'll have to wait for SW  to
>     replenish.




-- 
VGER BF report: U 0.499999
