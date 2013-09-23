From: Joe Perches <joe@perches.com>
Subject: [PATCH 04/12] wext.h: Remove extern from function prototypes
Date: Mon, 23 Sep 2013 11:33:42 -0700
Message-ID: <1a1b8a5b4611f667d321fbc722625f8e6caf2c9e.1379961014.git.joe@perches.com>
References: <445209f8885ccd8234fa787c30d63e63fc7917d7.1379961014.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <445209f8885ccd8234fa787c30d63e63fc7917d7.1379961014.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are a mix of function prototypes with and without extern
in the kernel sources.  Standardize on not using extern for
function prototypes.

Function prototypes don't need to be written with extern.
extern is assumed by the compiler.  Its use is as unnecessary as
using auto to declare automatic/local variables in a block.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/wext.h | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/net/wext.h b/include/net/wext.h
index 4f6e742..3459119 100644
--- a/include/net/wext.h
+++ b/include/net/wext.h
@@ -6,13 +6,13 @@
 struct net;
 
 #ifdef CONFIG_WEXT_CORE
-extern int wext_handle_ioctl(struct net *net, struct ifreq *ifr, unsigned int cmd,
-			     void __user *arg);
-extern int compat_wext_handle_ioctl(struct net *net, unsigned int cmd,
-				    unsigned long arg);
+int wext_handle_ioctl(struct net *net, struct ifreq *ifr, unsigned int cmd,
+		      void __user *arg);
+int compat_wext_handle_ioctl(struct net *net, unsigned int cmd,
+			     unsigned long arg);
 
-extern struct iw_statistics *get_wireless_stats(struct net_device *dev);
-extern int call_commit_handler(struct net_device *dev);
+struct iw_statistics *get_wireless_stats(struct net_device *dev);
+int call_commit_handler(struct net_device *dev);
 #else
 static inline int wext_handle_ioctl(struct net *net, struct ifreq *ifr, unsigned int cmd,
 				    void __user *arg)
@@ -27,8 +27,8 @@ static inline int compat_wext_handle_ioctl(struct net *net, unsigned int cmd,
 #endif
 
 #ifdef CONFIG_WEXT_PROC
-extern int wext_proc_init(struct net *net);
-extern void wext_proc_exit(struct net *net);
+int wext_proc_init(struct net *net);
+void wext_proc_exit(struct net *net);
 #else
 static inline int wext_proc_init(struct net *net)
 {
-- 
1.8.1.2.459.gbcd45b4.dirty
