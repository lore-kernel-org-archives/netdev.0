From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [BUG ?] irda: via-ircc: condition with no effect
Date: Sat, 13 Jun 2015 12:47:13 +0200
Message-ID: <1434192433-5934-1-git-send-email-hofrat@osadl.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicholas Mc Guire <hofrat@osadl.org>                                      

scanning for trivial bug-patters with coccinelle spatches returned:
./drivers/net/irda/via-ircc.c:598
	WARNING: condition with no effect (if branch == else)

This code was added prior to the transition to git (Linux-2.6.12-rc2) so
I was not really able to track back what the intent was.

drivers/net/irda/via-ircc.c - line numbers from 4.1-rc7
598                 if (IsSIROn(iobase)) {  //sir
599                         EnGPIOtoRX2(iobase, OFF);                          
600                         WriteGIO(iobase, OFF);
601                         EnRX2(iobase, OFF);     //sir to rx2
602                 } else {        // fir mir
603                         EnGPIOtoRX2(iobase, OFF);
604                         WriteGIO(iobase, OFF);
605                         EnRX2(iobase, OFF);     //fir to rx
606                 }

Given the comments that indicate that the if/else case actually are
different this may be a bug - if not the comments might need fixing.

thx!
hofrat
