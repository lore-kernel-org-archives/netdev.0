From: Chris Wright <chrisw@osdl.org>
Subject: [PATCH] ethtool_get_regs copy right number of bytes to user
Date: Tue, 15 Jun 2004 15:55:41 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040615155541.Q21045@build.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S266005AbUFOWzo@vger.kernel.org>
To: jgarzik@pobox.com
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

If regs.len is smaller than reglen it's possible to copy more bytes out
than the user asked for.

Signed-off-by: Chris Wright <chrisw@osdl.org>

===== net/core/ethtool.c 1.14 vs edited =====
--- 1.14/net/core/ethtool.c	2004-06-02 14:54:28 -07:00
+++ edited/net/core/ethtool.c	2004-06-13 12:59:15 -07:00
@@ -157,7 +157,7 @@
 	if (copy_to_user(useraddr, &regs, sizeof(regs)))
 		goto out;
 	useraddr += offsetof(struct ethtool_regs, data);
-	if (copy_to_user(useraddr, regbuf, reglen))
+	if (copy_to_user(useraddr, regbuf, regs.len))
 		goto out;
 	ret = 0;
 
