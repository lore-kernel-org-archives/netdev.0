From: Guenter Roeck <linux@roeck-us.net>
Subject: [RFC PATCH 06/11] next: mips: Fix malta_kvm_defconfig
Date: Sat, 20 Sep 2014 17:46:21 -0700
Message-ID: <1411260386-6800-7-git-send-email-linux@roeck-us.net>
References: <1411260386-6800-1-git-send-email-linux@roeck-us.net>
Cc: Randy Dunlap <rdunlap@infradead.org>,
	"David S. Miller" <davem@davemloft.net>,
	Anish Bhatt <anish@chelsio.com>, linux-mips@linux-mips.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Guenter Roeck <linux@roeck-us.net>
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1411260386-6800-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 5d6be6a5d486 ('scsi_netlink : Make SCSI_NETLINK dependent on NET instead
of selecting NET') changes 'select NET' to 'depends NET'. As a result, many
configurations which do not explicitly select CONFIG_NET are no longer valid
and need to be updated.

The command sequence to create the new configuration is as follows.

- Run "make ARCH=mips <configuration>" on upstream kernel
- Copy resulting .config to next-20140919
- Run "make ARCH=mips olddefconfig" in next-20140919
- Run "make ARCH=mips savedefconfig"
- Copy resulting defconfig file to arch/mips/configs/<configuration>
- Build the image with the resulting configuration

Fixes: 5d6be6a5d486 ('scsi_netlink : Make SCSI_NETLINK dependent on NET instead of selecting NET')
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 arch/mips/configs/malta_kvm_defconfig | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/arch/mips/configs/malta_kvm_defconfig b/arch/mips/configs/malta_kvm_defconfig
index cf0e01f..3c7150c 100644
--- a/arch/mips/configs/malta_kvm_defconfig
+++ b/arch/mips/configs/malta_kvm_defconfig
@@ -20,6 +20,7 @@ CONFIG_MODULE_UNLOAD=y
 CONFIG_MODVERSIONS=y
 CONFIG_MODULE_SRCVERSION_ALL=y
 CONFIG_PCI=y
+CONFIG_NET=y
 CONFIG_PACKET=y
 CONFIG_UNIX=y
 CONFIG_XFRM_USER=m
@@ -132,7 +133,6 @@ CONFIG_IP_NF_MATCH_ECN=m
 CONFIG_IP_NF_MATCH_TTL=m
 CONFIG_IP_NF_FILTER=m
 CONFIG_IP_NF_TARGET_REJECT=m
-CONFIG_IP_NF_TARGET_ULOG=m
 CONFIG_IP_NF_MANGLE=m
 CONFIG_IP_NF_TARGET_CLUSTERIP=m
 CONFIG_IP_NF_TARGET_ECN=m
@@ -175,7 +175,6 @@ CONFIG_BRIDGE_EBT_MARK_T=m
 CONFIG_BRIDGE_EBT_REDIRECT=m
 CONFIG_BRIDGE_EBT_SNAT=m
 CONFIG_BRIDGE_EBT_LOG=m
-CONFIG_BRIDGE_EBT_ULOG=m
 CONFIG_BRIDGE_EBT_NFLOG=m
 CONFIG_IP_SCTP=m
 CONFIG_BRIDGE=m
@@ -220,8 +219,6 @@ CONFIG_NET_ACT_SKBEDIT=m
 CONFIG_NET_CLS_IND=y
 CONFIG_CFG80211=m
 CONFIG_MAC80211=m
-CONFIG_MAC80211_RC_PID=y
-CONFIG_MAC80211_RC_DEFAULT_PID=y
 CONFIG_MAC80211_MESH=y
 CONFIG_RFKILL=m
 CONFIG_UEVENT_HELPER_PATH="/sbin/hotplug"
@@ -260,7 +257,6 @@ CONFIG_CHR_DEV_OSST=m
 CONFIG_BLK_DEV_SR=m
 CONFIG_BLK_DEV_SR_VENDOR=y
 CONFIG_CHR_DEV_SG=m
-CONFIG_SCSI_MULTI_LUN=y
 CONFIG_SCSI_CONSTANTS=y
 CONFIG_SCSI_LOGGING=y
 CONFIG_SCSI_SCAN_ASYNC=y
-- 
1.9.1
