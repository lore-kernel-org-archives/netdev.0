From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.5.72] ppp_async tty discipline module ref counting
Date: Thu, 19 Jun 2003 15:19:14 -0700
Sender: linux-ppp-owner@vger.kernel.org
Message-ID: <20030619151914.22988936.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-ppp@vger.kernel.org
Return-path: <linux-ppp-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>,
	Paul Mackerras <paulus@samba.org>
List-Id: netdev.vger.kernel.org

Change ppp_async to use the owner field to do the module reference counting
and eliminate the the MOD_INC/DEC calls.

diff -Nru a/drivers/net/ppp_async.c b/drivers/net/ppp_async.c
--- a/drivers/net/ppp_async.c	Thu Jun 19 15:15:56 2003
+++ b/drivers/net/ppp_async.c	Thu Jun 19 15:15:56 2003
@@ -147,7 +147,6 @@
 	struct asyncppp *ap;
 	int err;
 
-	MOD_INC_USE_COUNT;
 	err = -ENOMEM;
 	ap = kmalloc(sizeof(*ap), GFP_KERNEL);
 	if (ap == 0)
@@ -183,7 +182,6 @@
  out_free:
 	kfree(ap);
  out:
-	MOD_DEC_USE_COUNT;
 	return err;
 }
 
@@ -223,7 +221,6 @@
 	if (ap->tpkt != 0)
 		kfree_skb(ap->tpkt);
 	kfree(ap);
-	MOD_DEC_USE_COUNT;
 }
 
 /*
@@ -351,6 +348,7 @@
 
 
 static struct tty_ldisc ppp_ldisc = {
+	.owner  = THIS_MODULE,
 	.magic	= TTY_LDISC_MAGIC,
 	.name	= "ppp",
 	.open	= ppp_asynctty_open,
