From: "chas williams (contractor)" <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH] br2684 - use try_module_get appropriately
Date: Mon, 19 Jul 2004 17:36:05 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200407192136.i6JLa4QO028602@ginger.cmf.nrl.navy.mil>
References: <shemminger@osdl.org>
Cc: netdev@oss.sgi.com, Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: Message from Stephen Hemminger <shemminger@osdl.org>
   of "Mon, 28 Jun 2004 09:33:17 PDT." <20040628093317.218220fe@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <20040628093317.218220fe@dell_ss3.pdx.osdl.net>,Stephen Hemminger wr
ites:
>Either way, just an (void) try_module_get() is WRONG.

dave, please apply to 2.6  --thanks


# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1819  -> 1.1820 
#	   net/atm/pppoatm.c	1.12    -> 1.13   
#	    net/atm/br2684.c	1.12    -> 1.13   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/07/19	chas@relax.cmf.nrl.navy.mil	1.1820
# [ATM]: use try_module_get appropriately (from Stephen Hemminger <shemminger@osdl.org>)
# --------------------------------------------
#
diff -Nru a/net/atm/br2684.c b/net/atm/br2684.c
--- a/net/atm/br2684.c	Mon Jul 19 17:33:00 2004
+++ b/net/atm/br2684.c	Mon Jul 19 17:33:00 2004
@@ -563,7 +563,7 @@
 		BRPRIV(skb->dev)->stats.rx_packets--;
 		br2684_push(atmvcc, skb);
 	}
-	(void) try_module_get(THIS_MODULE);
+	__module_get(THIS_MODULE);
 	return 0;
     error:
 	write_unlock_irq(&devs_lock);
diff -Nru a/net/atm/pppoatm.c b/net/atm/pppoatm.c
--- a/net/atm/pppoatm.c	Mon Jul 19 17:33:00 2004
+++ b/net/atm/pppoatm.c	Mon Jul 19 17:33:00 2004
@@ -307,7 +307,7 @@
 	atmvcc->user_back = pvcc;
 	atmvcc->push = pppoatm_push;
 	atmvcc->pop = pppoatm_pop;
-	(void) try_module_get(THIS_MODULE);
+	__module_get(THIS_MODULE);
 	return 0;
 }
 
