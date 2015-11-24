From: Lan Tianyu <tianyu.lan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [RFC PATCH V2 2/3] PCI: Add macros for faked PCI migration capability
Date: Tue, 24 Nov 2015 21:38:17 +0800
Message-ID: <1448372298-28386-3-git-send-email-tianyu.lan@intel.com>
References: <1448372298-28386-1-git-send-email-tianyu.lan@intel.com>
To: a.motakis-lrHrjnjw1UfHK3s98zE1ajGjJy/sRE9J@public.gmane.org, alex.williamson-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	b.reynal-lrHrjnjw1UfHK3s98zE1ajGjJy/sRE9J@public.gmane.org, bhelgaas-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	carolyn.wyborny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, donald.c.skidmore-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	eddie.dong-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, nrupal.jani-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, agraf-l3A5Bk7waGM@public.gmane.org,
	kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, pbonzini-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, qemu-devel-qX2TKyscuCcdnm+yROfE0A@public.gmane.org,
	emil.s.tantilov-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	mark.d.rustad-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, eric.auger-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org,
	intel-wired-lan-qjLDD68F18P21nG7glBr7A@public.gmane.org, jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	jesse.brandeburg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, john.ronciak-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	matthew.vick-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, mitch.a.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, shannon.nelson-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	tianyu.lan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, weiyang-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1448372298-28386-1-git-send-email-tianyu.lan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch is to extend PCI CAP id for migration cap and
add reg macros. The CAP ID is trial and we may find better one if the
solution is feasible.

*PCI_VF_MIGRATION_CAP
For VF driver to  control that triggers mailbox irq or not during migration.

*PCI_VF_MIGRATION_VMM_STATUS
Qemu stores migration status in the reg

*PCI_VF_MIGRATION_VF_STATUS
VF driver tells Qemu ready for migration

*PCI_VF_MIGRATION_IRQ
VF driver stores mailbox interrupt vector in the reg for Qemu to trigger during migration.

Signed-off-by: Lan Tianyu <tianyu.lan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 include/uapi/linux/pci_regs.h | 18 +++++++++++++++++-
 1 file changed, 17 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/pci_regs.h b/include/uapi/linux/pci_regs.h
index efe3443..9defb6f 100644
--- a/include/uapi/linux/pci_regs.h
+++ b/include/uapi/linux/pci_regs.h
@@ -216,7 +216,8 @@
 #define  PCI_CAP_ID_MSIX	0x11	/* MSI-X */
 #define  PCI_CAP_ID_SATA	0x12	/* SATA Data/Index Conf. */
 #define  PCI_CAP_ID_AF		0x13	/* PCI Advanced Features */
-#define  PCI_CAP_ID_MAX		PCI_CAP_ID_AF
+#define  PCI_CAP_ID_MIGRATION	0X14   
+#define  PCI_CAP_ID_MAX		PCI_CAP_ID_MIGRATION
 #define PCI_CAP_LIST_NEXT	1	/* Next capability in the list */
 #define PCI_CAP_FLAGS		2	/* Capability defined flags (16 bits) */
 #define PCI_CAP_SIZEOF		4
@@ -904,4 +905,19 @@
 #define PCI_TPH_CAP_ST_SHIFT	16	/* st table shift */
 #define PCI_TPH_BASE_SIZEOF	12	/* size with no st table */
 
+/* Migration*/
+#define PCI_VF_MIGRATION_CAP		0x04
+#define PCI_VF_MIGRATION_VMM_STATUS	0x05
+#define PCI_VF_MIGRATION_VF_STATUS	0x06
+#define PCI_VF_MIGRATION_IRQ		0x07
+
+#define PCI_VF_MIGRATION_DISABLE	0x00
+#define PCI_VF_MIGRATION_ENABLE		0x01
+
+#define VMM_MIGRATION_END        0x00
+#define VMM_MIGRATION_START      0x01
+
+#define PCI_VF_WAIT_FOR_MIGRATION   0x00
+#define PCI_VF_READY_FOR_MIGRATION  0x01
+
 #endif /* LINUX_PCI_REGS_H */
-- 
1.8.4.rc0.1.g8f6a3e5.dirty
