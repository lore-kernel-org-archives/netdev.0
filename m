From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH] kexec: Export kexec_in_progress to modules
Date: Thu, 20 Oct 2016 18:15:16 -0700
Message-ID: <1477012516-20470-1-git-send-email-f.fainelli@gmail.com>
Cc: ebiederm@xmission.com, kexec@lists.infradead.org,
        linux-kernel@vger.kernel.org, davem@davemloft.net,
        sfr@canb.auug.org.au, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The bcm_sf2 driver uses kexec_in_progress to know whether it can power
down an integrated PHY during shutdown, and can be built as a module.
Other modules may be using this in the future, so export it.

Fixes: 2399d6143f85 ("net: dsa: bcm_sf2: Prevent GPHY shutdown for kexec'd kernels")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Eric, David, Stephen,

The offending commit is in David's net.git tree, so it would probably make
sense to route the fix through the same tree.

Thanks!

 kernel/kexec_core.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
index 561675589511..786ab85a5452 100644
--- a/kernel/kexec_core.c
+++ b/kernel/kexec_core.c
@@ -59,6 +59,7 @@ size_t vmcoreinfo_max_size = sizeof(vmcoreinfo_data);
 
 /* Flag to indicate we are going to kexec a new kernel */
 bool kexec_in_progress = false;
+EXPORT_SYMBOL_GPL(kexec_in_progress);
 
 
 /* Location of the reserved area for the crash kernel */
-- 
2.7.4
