From: clement.perrochaud-BPEPtVrvniRWk0Htik3J/w@public.gmane.org
Subject: [PATCH 2/4] NFC: nxp-nci: Add support for NXP NCI chips
Date: Thu, 22 Jan 2015 16:27:38 +0100
Message-ID: <1421940460-14049-3-git-send-email-clement.perrochaud@effinnov.com>
References: <1421940460-14049-1-git-send-email-clement.perrochaud@effinnov.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Cl=C3=A9ment=20Perrochaud?= <clement.perrochaud-3arQi8VN3Tc@public.gmane.org>,
	sunil.jogi-3arQi8VN3Tc@public.gmane.org, jerome.pele-3arQi8VN3Tc@public.gmane.org,
	Charles.Gorand-Effinnov-3arQi8VN3Tc@public.gmane.org, lauro.venancio-430g2QfJUUCGglJvpFV4uA@public.gmane.org,
	aloisio.almeida-430g2QfJUUCGglJvpFV4uA@public.gmane.org, sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org, galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, lefrique-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org,
	christophe.ricard-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, cuissard-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org,
	bzhao-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org, hirent-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org, akarwar-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	=?UTF-8?q?Cl=C3=A9ment=20Perrochaud?=
	<clement.perrochaud-BPEPtVrvniRWk0Htik3J/w@public.gmane.org>
To: linux-nfc-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1421940460-14049-1-git-send-email-clement.perrochaud-BPEPtVrvniRWk0Htik3J/w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Cl=C3=A9ment Perrochaud <clement.perrochaud-3arQi8VN3Tc@public.gmane.org>

Add support for NXP NCI NFC controllers.

Signed-off-by: Cl=C3=A9ment Perrochaud <clement.perrochaud-3arQi8VN3Tc@public.gmane.org>
Signed-off-by: Cl=C3=A9ment Perrochaud <clement.perrochaud-BPEPtVrvniRWk0Htik3J/w@public.gmane.org=
>
---
 MAINTAINERS                           |   9 +-
 drivers/nfc/Kconfig                   |   2 +
 drivers/nfc/Makefile                  |   1 +
 drivers/nfc/nxp-nci/Kconfig           |  12 ++
 drivers/nfc/nxp-nci/Makefile          |   9 +
 drivers/nfc/nxp-nci/core.c            | 187 ++++++++++++++++++++
 drivers/nfc/nxp-nci/firmware.c        | 321 ++++++++++++++++++++++++++=
++++++++
 drivers/nfc/nxp-nci/nxp-nci.h         |  91 ++++++++++
 include/linux/platform_data/nxp-nci.h |  27 +++
 9 files changed, 658 insertions(+), 1 deletion(-)
 create mode 100644 drivers/nfc/nxp-nci/Kconfig
 create mode 100644 drivers/nfc/nxp-nci/Makefile
 create mode 100644 drivers/nfc/nxp-nci/core.c
 create mode 100644 drivers/nfc/nxp-nci/firmware.c
 create mode 100644 drivers/nfc/nxp-nci/nxp-nci.h
 create mode 100644 include/linux/platform_data/nxp-nci.h

diff --git a/MAINTAINERS b/MAINTAINERS
index 7ec37a3..48b92f3 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -686,7 +686,7 @@ L:	alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org (moderated for non-s=
ubscribers)
 W:	http://blackfin.uclinux.org/
 S:	Supported
 F:	sound/soc/blackfin/*
-=20
+
 ANALOG DEVICES INC IIO DRIVERS
 M:	Lars-Peter Clausen <lars-Qo5EllUWu/uELgA04lAiVw@public.gmane.org>
 M:	Michael Hennerich <Michael.Hennerich-OyLXuOCK7orQT0dZR+AlfA@public.gmane.org>
@@ -6577,6 +6577,13 @@ S:	Supported
 F:	drivers/block/nvme*
 F:	include/linux/nvme.h
=20
+NXP-NCI NFC DRIVER
+M:	Cl=C3=A9ment Perrochaud <clement.perrochaud-BPEPtVrvniRWk0Htik3J/w@public.gmane.org>
+R:	Charles Gorand <charles.gorand-BPEPtVrvniRWk0Htik3J/w@public.gmane.org>
+L:	linux-nfc-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org (moderated for non-subscribers)
+S:	Supported
+F:	drivers/nfc/nxp-nci
+
 NXP TDA998X DRM DRIVER
 M:	Russell King <rmk+kernel-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
 S:	Supported
diff --git a/drivers/nfc/Kconfig b/drivers/nfc/Kconfig
index 7929fac..3da31e9 100644
--- a/drivers/nfc/Kconfig
+++ b/drivers/nfc/Kconfig
@@ -73,4 +73,6 @@ source "drivers/nfc/microread/Kconfig"
 source "drivers/nfc/nfcmrvl/Kconfig"
 source "drivers/nfc/st21nfca/Kconfig"
 source "drivers/nfc/st21nfcb/Kconfig"
+source "drivers/nfc/nxp-nci/Kconfig"
+
 endmenu
diff --git a/drivers/nfc/Makefile b/drivers/nfc/Makefile
index 6b23a2c..a4292d79 100644
--- a/drivers/nfc/Makefile
+++ b/drivers/nfc/Makefile
@@ -13,5 +13,6 @@ obj-$(CONFIG_NFC_MRVL)		+=3D nfcmrvl/
 obj-$(CONFIG_NFC_TRF7970A)	+=3D trf7970a.o
 obj-$(CONFIG_NFC_ST21NFCA)  	+=3D st21nfca/
 obj-$(CONFIG_NFC_ST21NFCB)	+=3D st21nfcb/
+obj-$(CONFIG_NFC_NXP_NCI)	+=3D nxp-nci/
=20
 ccflags-$(CONFIG_NFC_DEBUG) :=3D -DDEBUG
diff --git a/drivers/nfc/nxp-nci/Kconfig b/drivers/nfc/nxp-nci/Kconfig
new file mode 100644
index 0000000..5107edd
--- /dev/null
+++ b/drivers/nfc/nxp-nci/Kconfig
@@ -0,0 +1,12 @@
+config NFC_NXP_NCI
+	tristate "NXP-NCI NFC driver"
+	depends on NFC_NCI
+	default n
+	---help---
+	  Generic core driver for NXP NCI chips.
+	  This is a driver based on the NCI NFC kernel layers and
+	  will thus not work with NXP libnfc library.
+
+	  To compile this driver as a module, choose m here. The module will
+	  be called nxp_nci.
+	  Say N if unsure.
diff --git a/drivers/nfc/nxp-nci/Makefile b/drivers/nfc/nxp-nci/Makefil=
e
new file mode 100644
index 0000000..8f1e328
--- /dev/null
+++ b/drivers/nfc/nxp-nci/Makefile
@@ -0,0 +1,9 @@
+#
+# Makefile for NXP-NCI NFC driver
+#
+
+nxp-nci-objs =3D core.o firmware.o
+
+obj-$(CONFIG_NFC_NXP_NCI) +=3D nxp-nci.o
+
+ccflags-$(CONFIG_NFC_DEBUG) :=3D -DDEBUG
diff --git a/drivers/nfc/nxp-nci/core.c b/drivers/nfc/nxp-nci/core.c
new file mode 100644
index 0000000..d3643ef
--- /dev/null
+++ b/drivers/nfc/nxp-nci/core.c
@@ -0,0 +1,187 @@
+/*
+ * Generic driver for NXP NCI NFC chips
+ *
+ * Copyright (C) 2014  NXP Semiconductors  All rights reserved.
+ *
+ * Authors: Cl=C3=A9ment Perrochaud <clement.perrochaud-3arQi8VN3Tc@public.gmane.org>
+ *
+ * Derived from PN544 device driver:
+ * Copyright (C) 2012  Intel Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, see <http://www.gnu.org/licenses/>=
=2E
+ */
+
+#include <linux/delay.h>
+#include <linux/gpio.h>
+#include <linux/module.h>
+#include <linux/nfc.h>
+#include <linux/platform_data/nxp-nci.h>
+
+#include <net/nfc/nci_core.h>
+
+#include "nxp-nci.h"
+
+#define NXP_NCI_HDR_LEN	4
+
+#define NXP_NCI_NFC_PROTOCOLS (NFC_PROTO_JEWEL_MASK | \
+			       NFC_PROTO_MIFARE_MASK | \
+			       NFC_PROTO_FELICA_MASK | \
+			       NFC_PROTO_ISO14443_MASK | \
+			       NFC_PROTO_ISO14443_B_MASK | \
+			       NFC_PROTO_NFC_DEP_MASK)
+
+static int nxp_nci_open(struct nci_dev *ndev)
+{
+	struct nxp_nci_info *info =3D nci_get_drvdata(ndev);
+	int r =3D 0;
+
+	mutex_lock(&info->info_lock);
+
+	if (info->mode !=3D NXP_NCI_MODE_COLD) {
+		r =3D -EBUSY;
+		goto open_exit;
+	}
+
+	if (info->phy_ops->enable)
+		r =3D info->phy_ops->enable(info->phy_id);
+
+	info->mode =3D NXP_NCI_MODE_NCI;
+
+open_exit:
+	mutex_unlock(&info->info_lock);
+	return r;
+}
+
+static int nxp_nci_close(struct nci_dev *ndev)
+{
+	struct nxp_nci_info *info =3D nci_get_drvdata(ndev);
+	int r =3D 0;
+
+	mutex_lock(&info->info_lock);
+
+	if (info->phy_ops->disable)
+		r =3D info->phy_ops->disable(info->phy_id);
+
+	info->mode =3D NXP_NCI_MODE_COLD;
+
+	mutex_unlock(&info->info_lock);
+	return r;
+}
+
+static int nxp_nci_send(struct nci_dev *ndev, struct sk_buff *skb)
+{
+	struct nxp_nci_info *info =3D nci_get_drvdata(ndev);
+	int r;
+
+	if (!info->phy_ops->write) {
+		r =3D -ENOTSUPP;
+		goto send_exit;
+	}
+
+	if (info->mode !=3D NXP_NCI_MODE_NCI) {
+		r =3D -EINVAL;
+		goto send_exit;
+	}
+
+	r =3D info->phy_ops->write(info->phy_id, skb);
+	if (r < 0)
+		kfree_skb(skb);
+
+send_exit:
+	return r;
+}
+
+static struct nci_ops nxp_nci_ops =3D {
+	.open =3D nxp_nci_open,
+	.close =3D nxp_nci_close,
+	.send =3D nxp_nci_send,
+	.fw_download =3D nxp_nci_fw_download,
+};
+
+int nxp_nci_probe(void *phy_id, struct device *pdev,
+		  struct nxp_nci_phy_ops *phy_ops, unsigned int max_payload,
+		  struct nci_dev **ndev)
+{
+	struct nxp_nci_info *info;
+	int r;
+
+	info =3D devm_kzalloc(pdev, sizeof(struct nxp_nci_info), GFP_KERNEL);
+	if (!info) {
+		r =3D -ENOMEM;
+		goto probe_exit;
+	}
+
+	info->phy_id =3D phy_id;
+	info->pdev =3D pdev;
+	info->phy_ops =3D phy_ops;
+	info->max_payload =3D max_payload;
+	INIT_WORK(&info->fw_info.work, nxp_nci_fw_work);
+	init_completion(&info->fw_info.cmd_completion);
+	mutex_init(&info->info_lock);
+
+	if (info->phy_ops->disable) {
+		r =3D info->phy_ops->disable(info->phy_id);
+		if (r < 0)
+			goto probe_exit;
+	}
+
+	info->mode =3D NXP_NCI_MODE_COLD;
+
+	info->ndev =3D nci_allocate_device(&nxp_nci_ops, NXP_NCI_NFC_PROTOCOL=
S,
+					 NXP_NCI_HDR_LEN, 0);
+	if (!info->ndev) {
+		r =3D -ENOMEM;
+		goto probe_exit;
+	}
+
+	nci_set_parent_dev(info->ndev, pdev);
+	nci_set_drvdata(info->ndev, info);
+	r =3D nci_register_device(info->ndev);
+	if (r < 0)
+		goto probe_exit_free_nci;
+
+	*ndev =3D info->ndev;
+
+	goto probe_exit;
+
+probe_exit_free_nci:
+	nci_free_device(info->ndev);
+probe_exit:
+	return r;
+}
+EXPORT_SYMBOL(nxp_nci_probe);
+
+void nxp_nci_remove(struct nci_dev *ndev)
+{
+	struct nxp_nci_info *info =3D nci_get_drvdata(ndev);
+
+	mutex_lock(&info->info_lock);
+
+	cancel_work_sync(&info->fw_info.work);
+
+	if (info->mode =3D=3D NXP_NCI_MODE_FW)
+		nxp_nci_fw_work_complete(info, -ESHUTDOWN);
+
+	if (info->phy_ops->disable)
+		info->phy_ops->disable(info->phy_id);
+
+	nci_unregister_device(ndev);
+	nci_free_device(ndev);
+
+	mutex_unlock(&info->info_lock);
+}
+EXPORT_SYMBOL(nxp_nci_remove);
+
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("NXP NCI NFC driver");
+MODULE_AUTHOR("Cl=C3=A9ment Perrochaud <clement.perrochaud-3arQi8VN3Tc@public.gmane.org>");
diff --git a/drivers/nfc/nxp-nci/firmware.c b/drivers/nfc/nxp-nci/firmw=
are.c
new file mode 100644
index 0000000..1814e9f
--- /dev/null
+++ b/drivers/nfc/nxp-nci/firmware.c
@@ -0,0 +1,321 @@
+/*
+ * Generic driver for NXP NCI NFC chips
+ *
+ * Copyright (C) 2014  NXP Semiconductors  All rights reserved.
+ *
+ * Author: Cl=C3=A9ment Perrochaud <clement.perrochaud-3arQi8VN3Tc@public.gmane.org>
+ *
+ * Derived from PN544 device driver:
+ * Copyright (C) 2012  Intel Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, see <http://www.gnu.org/licenses/>=
=2E
+ */
+
+#include <linux/completion.h>
+#include <linux/firmware.h>
+#include <linux/nfc.h>
+#include <linux/unaligned/access_ok.h>
+
+#include "nxp-nci.h"
+
+/* Crypto operations can take up to 30 seconds */
+#define NXP_NCI_FW_ANSWER_TIMEOUT	msecs_to_jiffies(30000)
+
+#define NXP_NCI_FW_CMD_RESET		0xF0
+#define NXP_NCI_FW_CMD_GETVERSION	0xF1
+#define NXP_NCI_FW_CMD_CHECKINTEGRITY	0xE0
+#define NXP_NCI_FW_CMD_WRITE		0xC0
+#define NXP_NCI_FW_CMD_READ		0xA2
+#define NXP_NCI_FW_CMD_GETSESSIONSTATE	0xF2
+#define NXP_NCI_FW_CMD_LOG		0xA7
+#define NXP_NCI_FW_CMD_FORCE		0xD0
+#define NXP_NCI_FW_CMD_GET_DIE_ID	0xF4
+
+#define NXP_NCI_FW_CHUNK_FLAG	0x0400
+
+#define NXP_NCI_FW_RESULT_OK				0x00
+#define NXP_NCI_FW_RESULT_INVALID_ADDR			0x01
+#define NXP_NCI_FW_RESULT_GENERIC_ERROR			0x02
+#define NXP_NCI_FW_RESULT_UNKNOWN_CMD			0x0B
+#define NXP_NCI_FW_RESULT_ABORTED_CMD			0x0C
+#define NXP_NCI_FW_RESULT_PLL_ERROR			0x0D
+#define NXP_NCI_FW_RESULT_ADDR_RANGE_OFL_ERROR		0x1E
+#define NXP_NCI_FW_RESULT_BUFFER_OFL_ERROR		0x1F
+#define NXP_NCI_FW_RESULT_MEM_BSY			0x20
+#define NXP_NCI_FW_RESULT_SIGNATURE_ERROR		0x21
+#define NXP_NCI_FW_RESULT_FIRMWARE_VERSION_ERROR	0x24
+#define NXP_NCI_FW_RESULT_PROTOCOL_ERROR		0x28
+#define NXP_NCI_FW_RESULT_SFWU_DEGRADED			0x2A
+#define NXP_NCI_FW_RESULT_PH_STATUS_FIRST_CHUNK		0x2D
+#define NXP_NCI_FW_RESULT_PH_STATUS_NEXT_CHUNK		0x2E
+#define NXP_NCI_FW_RESULT_PH_STATUS_INTERNAL_ERROR_5	0xC5
+
+void nxp_nci_fw_work_complete(struct nxp_nci_info *info, int result)
+{
+	struct nxp_nci_fw_info *fw_info =3D &info->fw_info;
+	int r;
+
+	if (info->phy_ops->disable) {
+		r =3D info->phy_ops->disable(info->phy_id);
+		if (r < 0 && result =3D=3D 0)
+			result =3D -r;
+	}
+
+	info->mode =3D NXP_NCI_MODE_COLD;
+
+	if (fw_info->fw) {
+		release_firmware(fw_info->fw);
+		fw_info->fw =3D NULL;
+	}
+
+	nfc_fw_download_done(info->ndev->nfc_dev, fw_info->name, (u32) -resul=
t);
+}
+
+/* crc_ccitt cannot be used since it is computed MSB first and not LSB=
 first */
+static u16 nxp_nci_fw_crc(u8 const *buffer, size_t len)
+{
+	u16 crc =3D 0xffff;
+
+	while (len--) {
+		crc =3D ((crc >> 8) | (crc << 8)) ^ *buffer++;
+		crc ^=3D (crc & 0xff) >> 4;
+		crc ^=3D (crc & 0xff) << 12;
+		crc ^=3D (crc & 0xff) << 5;
+	}
+
+	return crc;
+}
+
+static int nxp_nci_fw_send_chunk(struct nxp_nci_info *info)
+{
+	struct nxp_nci_fw_info *fw_info =3D &info->fw_info;
+	u16 header, crc;
+	struct sk_buff *skb;
+	size_t chunk_len;
+	size_t remaining_len;
+	int r;
+
+	skb =3D nci_skb_alloc(info->ndev, info->max_payload, GFP_KERNEL);
+	if (!skb) {
+		r =3D -ENOMEM;
+		goto chunk_exit;
+	}
+
+	chunk_len =3D info->max_payload - NXP_NCI_FW_HDR_LEN - NXP_NCI_FW_CRC=
_LEN;
+	remaining_len =3D fw_info->frame_size - fw_info->written;
+
+	if (remaining_len > chunk_len) {
+		header =3D NXP_NCI_FW_CHUNK_FLAG;
+	} else {
+		chunk_len =3D remaining_len;
+		header =3D 0x0000;
+	}
+
+	header |=3D chunk_len & NXP_NCI_FW_FRAME_LEN_MASK;
+	put_unaligned_be16(header, skb_put(skb, NXP_NCI_FW_HDR_LEN));
+
+	memcpy(skb_put(skb, chunk_len), fw_info->data + fw_info->written,
+	       chunk_len);
+
+	crc =3D nxp_nci_fw_crc(skb->data, chunk_len + NXP_NCI_FW_HDR_LEN);
+	put_unaligned_be16(crc, skb_put(skb, NXP_NCI_FW_CRC_LEN));
+
+	r =3D info->phy_ops->write(info->phy_id, skb);
+	if (r >=3D 0)
+		r =3D chunk_len;
+
+	kfree_skb(skb);
+
+chunk_exit:
+	return r;
+}
+
+static int nxp_nci_fw_send(struct nxp_nci_info *info)
+{
+	struct nxp_nci_fw_info *fw_info =3D &info->fw_info;
+	long completion_rc;
+	int r;
+
+	reinit_completion(&fw_info->cmd_completion);
+
+	if (fw_info->written =3D=3D 0) {
+		fw_info->frame_size =3D get_unaligned_be16(fw_info->data) &
+				      NXP_NCI_FW_FRAME_LEN_MASK;
+		fw_info->data +=3D NXP_NCI_FW_HDR_LEN;
+		fw_info->size -=3D NXP_NCI_FW_HDR_LEN;
+	}
+
+	if (fw_info->frame_size > fw_info->size)
+		return -EMSGSIZE;
+
+	r =3D nxp_nci_fw_send_chunk(info);
+	if (r < 0)
+		return r;
+
+	fw_info->written +=3D r;
+
+	if (*fw_info->data =3D=3D NXP_NCI_FW_CMD_RESET) {
+		fw_info->cmd_result =3D 0;
+		schedule_work(&fw_info->work);
+	} else {
+		completion_rc =3D wait_for_completion_interruptible_timeout(
+			&fw_info->cmd_completion, NXP_NCI_FW_ANSWER_TIMEOUT);
+		if (completion_rc =3D=3D 0)
+			return -ETIMEDOUT;
+	}
+
+	return 0;
+}
+
+void nxp_nci_fw_work(struct work_struct *work)
+{
+	struct nxp_nci_info *info;
+	struct nxp_nci_fw_info *fw_info;
+	int r;
+
+	fw_info =3D container_of(work, struct nxp_nci_fw_info, work);
+	info =3D container_of(fw_info, struct nxp_nci_info, fw_info);
+
+	mutex_lock(&info->info_lock);
+
+	r =3D fw_info->cmd_result;
+	if (r < 0)
+		goto exit_work;
+
+	if (fw_info->written =3D=3D fw_info->frame_size) {
+		fw_info->data +=3D fw_info->frame_size;
+		fw_info->size -=3D fw_info->frame_size;
+		fw_info->written =3D 0;
+	}
+
+	if (fw_info->size > 0)
+		r =3D nxp_nci_fw_send(info);
+
+exit_work:
+	if (r < 0 || fw_info->size =3D=3D 0)
+		nxp_nci_fw_work_complete(info, r);
+	mutex_unlock(&info->info_lock);
+}
+
+int nxp_nci_fw_download(struct nci_dev *ndev, const char *firmware_nam=
e)
+{
+	struct nxp_nci_info *info =3D nci_get_drvdata(ndev);
+	struct nxp_nci_fw_info *fw_info =3D &info->fw_info;
+	int r;
+
+	mutex_lock(&info->info_lock);
+
+	if (!info->phy_ops->fw_enable || !info->phy_ops->write) {
+		r =3D -ENOTSUPP;
+		goto fw_download_exit;
+	}
+
+	if (!firmware_name || firmware_name[0] =3D=3D '\0') {
+		r =3D -EINVAL;
+		goto fw_download_exit;
+	}
+
+	strcpy(fw_info->name, firmware_name);
+
+	r =3D request_firmware(&fw_info->fw, firmware_name,
+			     ndev->nfc_dev->dev.parent);
+	if (r < 0)
+		goto fw_download_exit;
+
+	r =3D info->phy_ops->fw_enable(info->phy_id);
+	if (r < 0)
+		goto fw_download_exit;
+
+	info->mode =3D NXP_NCI_MODE_FW;
+
+	fw_info->data =3D fw_info->fw->data;
+	fw_info->size =3D fw_info->fw->size;
+	fw_info->written =3D 0;
+	fw_info->frame_size =3D 0;
+	fw_info->cmd_result =3D 0;
+
+	schedule_work(&fw_info->work);
+
+fw_download_exit:
+	mutex_unlock(&info->info_lock);
+	return r;
+}
+
+static int nxp_nci_fw_read_status(u8 stat)
+{
+	switch (stat) {
+	case NXP_NCI_FW_RESULT_OK:
+		return 0;
+	case NXP_NCI_FW_RESULT_INVALID_ADDR:
+		return -EINVAL;
+	case NXP_NCI_FW_RESULT_UNKNOWN_CMD:
+		return -EINVAL;
+	case NXP_NCI_FW_RESULT_ABORTED_CMD:
+		return -EMSGSIZE;
+	case NXP_NCI_FW_RESULT_ADDR_RANGE_OFL_ERROR:
+		return -EADDRNOTAVAIL;
+	case NXP_NCI_FW_RESULT_BUFFER_OFL_ERROR:
+		return -ENOBUFS;
+	case NXP_NCI_FW_RESULT_MEM_BSY:
+		return -ENOKEY;
+	case NXP_NCI_FW_RESULT_SIGNATURE_ERROR:
+		return -EKEYREJECTED;
+	case NXP_NCI_FW_RESULT_FIRMWARE_VERSION_ERROR:
+		return -EALREADY;
+	case NXP_NCI_FW_RESULT_PROTOCOL_ERROR:
+		return -EPROTO;
+	case NXP_NCI_FW_RESULT_SFWU_DEGRADED:
+		return -EHWPOISON;
+	case NXP_NCI_FW_RESULT_PH_STATUS_FIRST_CHUNK:
+		return 0;
+	case NXP_NCI_FW_RESULT_PH_STATUS_NEXT_CHUNK:
+		return 0;
+	case NXP_NCI_FW_RESULT_PH_STATUS_INTERNAL_ERROR_5:
+		return -EINVAL;
+	default:
+		return -EIO;
+	}
+}
+
+static u16 nxp_nci_fw_check_crc(struct sk_buff *skb)
+{
+	u16 crc, frame_crc;
+	size_t len =3D skb->len - NXP_NCI_FW_CRC_LEN;
+
+	crc =3D nxp_nci_fw_crc(skb->data, len);
+	frame_crc =3D get_unaligned_be16(skb->data + len);
+
+	return (crc ^ frame_crc);
+}
+
+void nxp_nci_fw_recv_frame(struct nci_dev *ndev, struct sk_buff *skb)
+{
+	struct nxp_nci_info *info =3D nci_get_drvdata(ndev);
+	struct nxp_nci_fw_info *fw_info =3D &info->fw_info;
+
+	complete(&fw_info->cmd_completion);
+
+	if (skb) {
+		if (nxp_nci_fw_check_crc(skb) !=3D 0x00)
+			fw_info->cmd_result =3D -EBADMSG;
+		else
+			fw_info->cmd_result =3D nxp_nci_fw_read_status(
+					*skb_pull(skb, NXP_NCI_FW_HDR_LEN));
+		kfree_skb(skb);
+	} else {
+		fw_info->cmd_result =3D -EIO;
+	}
+
+	schedule_work(&fw_info->work);
+}
+EXPORT_SYMBOL(nxp_nci_fw_recv_frame);
diff --git a/drivers/nfc/nxp-nci/nxp-nci.h b/drivers/nfc/nxp-nci/nxp-nc=
i.h
new file mode 100644
index 0000000..4309328
--- /dev/null
+++ b/drivers/nfc/nxp-nci/nxp-nci.h
@@ -0,0 +1,91 @@
+/*
+ * Copyright (C) 2014  NXP Semiconductors  All rights reserved.
+ *
+ * Authors: Cl=C3=A9ment Perrochaud <clement.perrochaud-3arQi8VN3Tc@public.gmane.org>
+ *
+ * Derived from PN544 device driver:
+ * Copyright (C) 2012  Intel Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, see <http://www.gnu.org/licenses/>=
=2E
+*/
+
+#ifndef __LOCAL_NXP_NCI_H_
+#define __LOCAL_NXP_NCI_H_
+
+#include <linux/completion.h>
+#include <linux/firmware.h>
+#include <linux/nfc.h>
+#include <linux/platform_data/nxp-nci.h>
+
+#include <net/nfc/nci_core.h>
+
+#define NXP_NCI_FW_HDR_LEN	2
+#define NXP_NCI_FW_CRC_LEN	2
+
+#define NXP_NCI_FW_FRAME_LEN_MASK	0x03FF
+
+enum nxp_nci_mode {
+	NXP_NCI_MODE_COLD,
+	NXP_NCI_MODE_NCI,
+	NXP_NCI_MODE_FW
+};
+
+struct nxp_nci_phy_ops {
+	int (*enable)(void *id);
+	int (*fw_enable)(void *id);
+	int (*disable)(void *id);
+	int (*write)(void *id, struct sk_buff *skb);
+};
+
+struct nxp_nci_fw_info {
+	char name[NFC_FIRMWARE_NAME_MAXSIZE + 1];
+	const struct firmware *fw;
+
+	size_t size;
+	size_t written;
+
+	const u8 *data;
+	size_t frame_size;
+
+	struct work_struct work;
+	struct completion cmd_completion;
+
+	int cmd_result;
+};
+
+struct nxp_nci_info {
+	struct nci_dev *ndev;
+	void *phy_id;
+	struct device *pdev;
+
+	enum nxp_nci_mode mode;
+
+	struct nxp_nci_phy_ops *phy_ops;
+	unsigned int max_payload;
+
+	struct mutex info_lock;
+
+	struct nxp_nci_fw_info fw_info;
+};
+
+int nxp_nci_fw_download(struct nci_dev *ndev, const char *firmware_nam=
e);
+void nxp_nci_fw_work(struct work_struct *work);
+void nxp_nci_fw_recv_frame(struct nci_dev *ndev, struct sk_buff *skb);
+void nxp_nci_fw_work_complete(struct nxp_nci_info *info, int result);
+
+int nxp_nci_probe(void *phy_id, struct device *pdev,
+		  struct nxp_nci_phy_ops *phy_ops, unsigned int max_payload,
+		  struct nci_dev **ndev);
+void nxp_nci_remove(struct nci_dev *ndev);
+
+#endif /* __LOCAL_NXP_NCI_H_ */
diff --git a/include/linux/platform_data/nxp-nci.h b/include/linux/plat=
form_data/nxp-nci.h
new file mode 100644
index 0000000..d6ed286
--- /dev/null
+++ b/include/linux/platform_data/nxp-nci.h
@@ -0,0 +1,27 @@
+/*
+ * Generic platform data for the NXP NCI NFC chips.
+ *
+ * Copyright (C) 2014  NXP Semiconductors  All rights reserved.
+ *
+ * Authors: Cl=C3=A9ment Perrochaud <clement.perrochaud-3arQi8VN3Tc@public.gmane.org>
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ */
+
+#ifndef _NXP_NCI_H_
+#define _NXP_NCI_H_
+
+struct nxp_nci_nfc_platform_data {
+	unsigned int gpio_en;
+	unsigned int gpio_fw;
+	unsigned int irq;
+};
+
+#endif /* _NXP_NCI_H_ */
--=20
Cl=C3=A9ment Perrochaud

Eff'Innov Technologies
Caen, Aix-En-Provence, Grenoble

Eff'Innov Technologies
Campus EffiScience
2, Esplanade Anton Philips
14460 Colombelles, FRANCE

http://www.effinnov.com

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
