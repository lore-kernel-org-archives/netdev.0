From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCH] smc911x: Re-release spinlock on spurious interrupt
Date: Thu, 20 Jul 2006 06:01:47 +0200
Message-ID: <87hd1cj55g.fsf@slug.be.48ers.dk>
References: <87psg1hqp8.fsf@slug.be.48ers.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030354AbWGTQCx@vger.kernel.org>
To: dustin@sensoria.com
In-Reply-To: <87psg1hqp8.fsf@slug.be.48ers.dk> (Peter Korsgaard's message of
	"Thu, 20 Jul 2006 05:59:15 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>>> "Peter" == Peter Korsgaard <jacmet@sunsite.dk> writes:

 Peter> Hi,
 Peter> The smc911x driver forgets to release the spinlock on spurious
 Peter> interrupts. This little patch fixes it.

Crap - forgot to sign off :/

Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>

diff -Naur linux-2.6.18-rc2.orig/drivers/net/smc911x.c linux-2.6.18-rc2/drivers/net/smc911x.c
--- linux-2.6.18-rc2.orig/drivers/net/smc911x.c	2006-07-20 10:26:20.000000000 +0200
+++ linux-2.6.18-rc2/drivers/net/smc911x.c	2006-07-20 17:44:26.000000000 +0200
@@ -1092,6 +1092,7 @@
 	/* Spurious interrupt check */
 	if ((SMC_GET_IRQ_CFG() & (INT_CFG_IRQ_INT_ | INT_CFG_IRQ_EN_)) !=
 		(INT_CFG_IRQ_INT_ | INT_CFG_IRQ_EN_)) {
+		spin_unlock_irqrestore(&lp->lock, flags);
 		return IRQ_NONE;
 	}

-- 
Bye, Peter Korsgaard
