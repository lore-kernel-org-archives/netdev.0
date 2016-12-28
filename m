From: Augusto Mecking Caringi <augustocaringi@gmail.com>
Subject: [PATCH] net: atm: Fix warnings in net/atm/lec.c when !CONFIG_PROC_FS
Date: Wed, 28 Dec 2016 16:02:05 +0000
Message-ID: <1482941006-28052-1-git-send-email-augustocaringi@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Augusto Mecking Caringi <augustocaringi@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Felipe Balbi <felipe.balbi@linux.intel.com>,
        Kees Cook <keescook@chromium.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Jarod Wilson <jarod@redhat.com>,
        Javier Martinez Canillas <javier@osg.samsung.com>,
        Florian Westphal <fw@strlen.de>, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes the following warnings when CONFIG_PROC_FS is not set:

linux/net/atm/lec.c: In function ‘lane_module_cleanup’:
linux/net/atm/lec.c:1062:27: error: ‘atm_proc_root’ undeclared (first
use in this function)
remove_proc_entry("lec", atm_proc_root);
                           ^
linux/net/atm/lec.c:1062:27: note: each undeclared identifier is
reported only once for each function it appears in

Signed-off-by: Augusto Mecking Caringi <augustocaringi@gmail.com>
---
 net/atm/lec.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/atm/lec.c b/net/atm/lec.c
index 019557d..09cfe87 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -1059,7 +1059,9 @@ static void __exit lane_module_cleanup(void)
 {
 	int i;
 
+#ifdef CONFIG_PROC_FS
 	remove_proc_entry("lec", atm_proc_root);
+#endif
 
 	deregister_atm_ioctl(&lane_ioctl_ops);
 
-- 
2.7.4
