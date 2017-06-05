From: Joe Perches <joe@perches.com>
Subject: [PATCH] ppp: mppe: Use vsnprintf extension %phN
Date: Mon,  5 Jun 2017 05:22:50 -0700
Message-ID: <80f51106926c82374f6555b54af71a674b8bf94e.1496665332.git.joe@perches.com>
Cc: linux-ppp@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Paul Mackerras <paulus@samba.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using this extension reduces the object size.

$ size drivers/net/ppp/ppp_mppe.o*
   text	   data	    bss	    dec	    hex	filename
   5683	    216	      8	   5907	   1713	drivers/net/ppp/ppp_mppe.o.new
   5808	    216	      8	   6032	   1790	drivers/net/ppp/ppp_mppe.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ppp/ppp_mppe.c | 15 ++++-----------
 1 file changed, 4 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ppp/ppp_mppe.c b/drivers/net/ppp/ppp_mppe.c
index f60f7660b451..6c7fd98cb00a 100644
--- a/drivers/net/ppp/ppp_mppe.c
+++ b/drivers/net/ppp/ppp_mppe.c
@@ -298,21 +298,14 @@ mppe_init(void *arg, unsigned char *options, int optlen, int unit, int debug,
 	mppe_rekey(state, 1);
 
 	if (debug) {
-		int i;
-		char mkey[sizeof(state->master_key) * 2 + 1];
-		char skey[sizeof(state->session_key) * 2 + 1];
-
 		printk(KERN_DEBUG "%s[%d]: initialized with %d-bit %s mode\n",
 		       debugstr, unit, (state->keylen == 16) ? 128 : 40,
 		       (state->stateful) ? "stateful" : "stateless");
-
-		for (i = 0; i < sizeof(state->master_key); i++)
-			sprintf(mkey + i * 2, "%02x", state->master_key[i]);
-		for (i = 0; i < sizeof(state->session_key); i++)
-			sprintf(skey + i * 2, "%02x", state->session_key[i]);
 		printk(KERN_DEBUG
-		       "%s[%d]: keys: master: %s initial session: %s\n",
-		       debugstr, unit, mkey, skey);
+		       "%s[%d]: keys: master: %*phN initial session: %*phN\n",
+		       debugstr, unit,
+		       (int)sizeof(state->master_key), state->master_key,
+		       (int)sizeof(state->session_key), state->session_key);
 	}
 
 	/*
-- 
2.10.0.rc2.1.g053435c
