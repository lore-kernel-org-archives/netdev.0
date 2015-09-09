From: Palmer Dabbelt <palmer@dabbelt.com>
Subject: [PATCH 03/13] Hide COMPAT_ATM_ADDPARTY behind #ifdef __KERNEL__
Date: Wed,  9 Sep 2015 14:08:12 -0700
Message-ID: <1441832902-28993-4-git-send-email-palmer@dabbelt.com>
References: <2644177.lVCYzIBfPW@wuerfel>
 <1441832902-28993-1-git-send-email-palmer@dabbelt.com>
Cc: 3chas3@gmail.com
To: arnd@arndb.de
Return-path: <linux-arch-owner@vger.kernel.org>
Cc: hpa@zytor.com
Cc: mingo@redhat.com
Cc: plagnioj@jcrosoft.com
Cc: jikos@kernel.org
Cc: linux-api@vger.kernel.org
Cc: linux-arch@vger.kernel.org
Cc: linux-atm-general@lists.sourceforge.net
Cc: linux-fbdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: tglx@linutronix.de
Cc: tomi.valkeinen@ti.com
Cc: x86@kernel.org
Cc: Palmer Dabbelt <palmer@dabbelt.com>
In-Reply-To: <1441832902-28993-1-git-send-email-palmer@dabbelt.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This used to just be behind an #ifdef COMPAT_COMPAT, so most of
userspace wouldn't have seen the definition before.  This change just
makes the __KERNEL__ part explicit to quiet the header checker.

Signed-off-by: Palmer Dabbelt <palmer@dabbelt.com>
Reviewed-by: Andrew Waterman <waterman@eecs.berkeley.edu>
Reviewed-by: Albert Ou <aou@eecs.berkeley.edu>
---
 include/uapi/linux/atmdev.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/uapi/linux/atmdev.h b/include/uapi/linux/atmdev.h
index 93e0ec008ca8..f8b6223165da 100644
--- a/include/uapi/linux/atmdev.h
+++ b/include/uapi/linux/atmdev.h
@@ -100,7 +100,7 @@ struct atm_dev_stats {
 					/* use backend to make new if */
 #define ATM_ADDPARTY  	_IOW('a', ATMIOC_SPECIAL+4,struct atm_iobuf)
  					/* add party to p2mp call */
-#ifdef CONFIG_COMPAT
+#if defined(__KERNEL__) && defined(CONFIG_COMPAT)
 /* It actually takes struct sockaddr_atmsvc, not struct atm_iobuf */
 #define COMPAT_ATM_ADDPARTY  	_IOW('a', ATMIOC_SPECIAL+4,struct compat_atm_iobuf)
 #endif
-- 
2.4.6
