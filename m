From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] ser_gigaset: return -ENOMEM on error instead of success
Date: Wed, 7 Dec 2016 14:22:03 +0300
Message-ID: <20161207112203.GC5507@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Karsten Keil <isdn@linux-pingi.de>,
        "David S. Miller" <davem@davemloft.net>,
        gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Paul Bolle <pebolle@tiscali.nl>, Tilman Schmidt <tilman@imap.cc>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If we can't allocate the resources in gigaset_initdriver() then we
should return -ENOMEM instead of zero.

Fixes: 2869b23e4b95 ("[PATCH] drivers/isdn/gigaset: new M101 driver (v2)")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
Ancient code.

diff --git a/drivers/isdn/gigaset/ser-gigaset.c b/drivers/isdn/gigaset/ser-gigaset.c
index d1f8ab915b15..b90776ef56ec 100644
--- a/drivers/isdn/gigaset/ser-gigaset.c
+++ b/drivers/isdn/gigaset/ser-gigaset.c
@@ -755,8 +755,10 @@ static int __init ser_gigaset_init(void)
 	driver = gigaset_initdriver(GIGASET_MINOR, GIGASET_MINORS,
 				    GIGASET_MODULENAME, GIGASET_DEVNAME,
 				    &ops, THIS_MODULE);
-	if (!driver)
+	if (!driver) {
+		rc = -ENOMEM;
 		goto error;
+	}
 
 	rc = tty_register_ldisc(N_GIGASET_M101, &gigaset_ldisc);
 	if (rc != 0) {
