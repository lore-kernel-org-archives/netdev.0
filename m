From: Chris Wright <chrisw@osdl.org>
Subject: [PATCH] remove redundant check in de2104x ->get_regs()
Date: Fri, 16 Apr 2004 15:37:54 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040416153754.U21045@build.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Jeff,

Trivial patchlet...ethtool core already caps regs.len at a max of
->get_regs_len():

	reglen = ops->get_regs_len(dev);
	if (regs.len > reglen)
		regs.len = reglen;

So doing the same in the in de2104x driver ->get_regs() is redundant.
Patch below simply removes it to clarify the guarantee of the API.

thanks,
-chris
-- 
Linux Security Modules     http://lsm.immunix.org     http://lsm.bkbits.net

===== drivers/net/tulip/de2104x.c 1.29 vs edited =====
--- 1.29/drivers/net/tulip/de2104x.c	Wed Mar 17 11:32:53 2004
+++ edited/drivers/net/tulip/de2104x.c	Fri Apr 16 15:31:55 2004
@@ -1676,8 +1676,6 @@
 {
 	struct de_private *de = dev->priv;
 
-	if (regs->len > DE_REGS_SIZE)
-		regs->len = DE_REGS_SIZE;
 	regs->version = (DE_REGS_VER << 2) | de->de21040;
 
 	spin_lock_irq(&de->lock);
