From: Florian Westphal <fw@strlen.de>
Subject: [PATCH] compat_ioctl: add compat handler for PPPIOCGL2TPSTATS
Date: Sun,  7 Aug 2011 00:12:04 +0200
Message-ID: <1312668724-10877-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>,
	James Chapman <jchapman@katalix.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	linux-fsdevel@vger.kernel.org
To: <netdev@vger.kernel.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

fixes following error seen on x86_64 kernel:
ioctl32(openl2tpd:7480): Unknown cmd fd(14) cmd(80487436){t:'t';sz:72} arg(ffa7e6c0) on socket:[105094]

The argument (struct pppol2tp_ioc_stats) uses "aligned_u64" and thus doesn't need
fixups.

Cc: James Chapman <jchapman@katalix.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Signed-off-by: Florian Westphal <fw@strlen.de>
---
diff --git a/fs/compat_ioctl.c b/fs/compat_ioctl.c
index 8be086e..51352de 100644
--- a/fs/compat_ioctl.c
+++ b/fs/compat_ioctl.c
@@ -1003,6 +1003,7 @@ COMPATIBLE_IOCTL(PPPIOCCONNECT)
 COMPATIBLE_IOCTL(PPPIOCDISCONN)
 COMPATIBLE_IOCTL(PPPIOCATTCHAN)
 COMPATIBLE_IOCTL(PPPIOCGCHAN)
+COMPATIBLE_IOCTL(PPPIOCGL2TPSTATS)
 /* PPPOX */
 COMPATIBLE_IOCTL(PPPOEIOCSFWD)
 COMPATIBLE_IOCTL(PPPOEIOCDFWD)
-- 
1.7.3.4

