From: Igor Mammedov <imammedo@redhat.com>
Subject: [PATCH] vhost: support upto 509 memory regions
Date: Fri, 13 Feb 2015 15:49:59 +0000
Message-ID: <1423842599-5174-1-git-send-email-imammedo@redhat.com>
Cc: mst@redhat.com, kvm@vger.kernel.org, netdev@vger.kernel.org,
	pbonzini@redhat.com
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

since commit
 1d4e7e3 kvm: x86: increase user memory slots to 509

it became possible to use a bigger amount of memory
slots, which is used by memory hotplug for
registering hotplugged memory.
However QEMU aborts if it's used with more than ~60
pc-dimm devices and vhost-net since host kernel
in module vhost-net refuses to accept more than 65
memory regions.

Increasing VHOST_MEMORY_MAX_NREGIONS from 65 to 509
to match KVM_USER_MEM_SLOTS fixes issue for vhost-net.

Signed-off-by: Igor Mammedov <imammedo@redhat.com>
---
 drivers/vhost/vhost.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 2ee2826..ecbd7a4 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -29,7 +29,7 @@
 #include "vhost.h"
 
 enum {
-	VHOST_MEMORY_MAX_NREGIONS = 64,
+	VHOST_MEMORY_MAX_NREGIONS = 509,
 	VHOST_MEMORY_F_LOG = 0x1,
 };
 
-- 
1.8.3.1
