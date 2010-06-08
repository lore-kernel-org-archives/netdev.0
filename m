From: Rakesh Ranjan <rakesh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 1/3] cxgb4i_v4.3 : add build support
Date: Tue,  8 Jun 2010 10:29:25 +0530
Message-ID: <1275973167-8640-2-git-send-email-rakesh@chelsio.com>
References: <1275973167-8640-1-git-send-email-rakesh@chelsio.com>
Reply-To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Karen Xie <kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        James Bottomley <James.Bottomley-JuX6DAaQMKPCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>,
        Mike Christie <michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org>, Anish Bhatt <anish-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
        Rakesh Ranjan <rakesh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: LK-NetDev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        LK-SCSIDev <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        LK-iSCSIDev <open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Return-path: <open-iscsi+bncCKnrzee6GxDgnLfgBBoEclmVtw-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <1275973167-8640-1-git-send-email-rakesh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
List-Post: <http://groups.google.com/group/open-iscsi/post?hl=en_US>,
	<mailto:open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/?hl=en_US>, <mailto:open-iscsi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/open-iscsi?hl=en_US>
Sender: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/open-iscsi/subscribe?hl=en_US>,
	<mailto:open-iscsi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/open-iscsi/subscribe?hl=en_US>,
	<mailto:open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Rakesh Ranjan <rakesh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>


Signed-off-by: Rakesh Ranjan <rakesh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
---
 drivers/scsi/Kconfig       |    1 +
 drivers/scsi/Makefile      |    1 +
 drivers/scsi/cxgbi/Kbuild  |    5 +++++
 drivers/scsi/cxgbi/Kconfig |    7 +++++++
 4 files changed, 14 insertions(+), 0 deletions(-)
 create mode 100644 drivers/scsi/cxgbi/Kbuild
 create mode 100644 drivers/scsi/cxgbi/Kconfig

diff --git a/drivers/scsi/Kconfig b/drivers/scsi/Kconfig
index 75f2336..70983a8 100644
--- a/drivers/scsi/Kconfig
+++ b/drivers/scsi/Kconfig
@@ -371,6 +371,7 @@ config ISCSI_TCP
 	 http://open-iscsi.org
 
 source "drivers/scsi/cxgb3i/Kconfig"
+source "drivers/scsi/cxgbi/Kconfig"
 source "drivers/scsi/bnx2i/Kconfig"
 source "drivers/scsi/be2iscsi/Kconfig"
 
diff --git a/drivers/scsi/Makefile b/drivers/scsi/Makefile
index 1c7ac49..b0873aa 100644
--- a/drivers/scsi/Makefile
+++ b/drivers/scsi/Makefile
@@ -133,6 +133,7 @@ obj-$(CONFIG_SCSI_STEX)		+= stex.o
 obj-$(CONFIG_SCSI_MVSAS)	+= mvsas/
 obj-$(CONFIG_PS3_ROM)		+= ps3rom.o
 obj-$(CONFIG_SCSI_CXGB3_ISCSI)	+= libiscsi.o libiscsi_tcp.o cxgb3i/
+obj-$(CONFIG_SCSI_CXGB4_ISCSI)	+= libiscsi.o libiscsi_tcp.o cxgbi/
 obj-$(CONFIG_SCSI_BNX2_ISCSI)	+= libiscsi.o bnx2i/
 obj-$(CONFIG_BE2ISCSI)		+= libiscsi.o be2iscsi/
 obj-$(CONFIG_SCSI_PMCRAID)	+= pmcraid.o
diff --git a/drivers/scsi/cxgbi/Kbuild b/drivers/scsi/cxgbi/Kbuild
new file mode 100644
index 0000000..03291c5
--- /dev/null
+++ b/drivers/scsi/cxgbi/Kbuild
@@ -0,0 +1,5 @@
+EXTRA_CFLAGS += -I$(srctree)/drivers/net/cxgb4
+
+obj-$(CONFIG_SCSI_CXGB4_ISCSI) += cxgb4i.o libcxgbi.o
+cxgb4i-y := cxgb4i_init.o cxgb4i_offload.o cxgb4i_ddp.o
+
diff --git a/drivers/scsi/cxgbi/Kconfig b/drivers/scsi/cxgbi/Kconfig
new file mode 100644
index 0000000..3f33dc2
--- /dev/null
+++ b/drivers/scsi/cxgbi/Kconfig
@@ -0,0 +1,7 @@
+config SCSI_CXGB4_ISCSI
+	tristate "Chelsio T4 iSCSI support"
+	depends on CHELSIO_T4_DEPENDS
+	select CHELSIO_T4
+	select SCSI_ISCSI_ATTRS
+	---help---
+	This driver supports iSCSI offload for the Chelsio T4 series devices.
-- 
1.6.6.1

-- 
You received this message because you are subscribed to the Google Groups "open-iscsi" group.
To post to this group, send email to open-iscsi-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
To unsubscribe from this group, send email to open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
For more options, visit this group at http://groups.google.com/group/open-iscsi?hl=en.
