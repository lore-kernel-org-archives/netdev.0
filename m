From: clement.perrochaud-BPEPtVrvniRWk0Htik3J/w@public.gmane.org
Subject: [PATCH 3/4] NFC: nxp-nci_i2c: Add I2C support to NXP NCI driver
Date: Thu, 22 Jan 2015 16:27:39 +0100
Message-ID: <1421940460-14049-4-git-send-email-clement.perrochaud@effinnov.com>
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
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1421940460-14049-1-git-send-email-clement.perrochaud-BPEPtVrvniRWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Cl=C3=A9ment Perrochaud <clement.perrochaud-3arQi8VN3Tc@public.gmane.org>

Signed-off-by: Cl=C3=A9ment Perrochaud <clement.perrochaud-3arQi8VN3Tc@public.gmane.org>
Signed-off-by: Cl=C3=A9ment Perrochaud <clement.perrochaud-BPEPtVrvniRWk0Htik3J/w@public.gmane.org=
>
---
 .../devicetree/bindings/net/nfc/nxp-nci.txt        |  35 ++
 drivers/nfc/nxp-nci/Kconfig                        |  12 +
 drivers/nfc/nxp-nci/Makefile                       |   2 +
 drivers/nfc/nxp-nci/i2c.c                          | 468 +++++++++++++=
++++++++
 4 files changed, 517 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/nfc/nxp-nci.t=
xt
 create mode 100644 drivers/nfc/nxp-nci/i2c.c

diff --git a/Documentation/devicetree/bindings/net/nfc/nxp-nci.txt b/Do=
cumentation/devicetree/bindings/net/nfc/nxp-nci.txt
new file mode 100644
index 0000000..5b6cd9b
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/nfc/nxp-nci.txt
@@ -0,0 +1,35 @@
+* NXP Semiconductors NXP NCI NFC Controllers
+
+Required properties:
+- compatible: Should be "nxp,nxp-nci-i2c".
+- clock-frequency: I=C2=B2C work frequency.
+- reg: address on the bus
+- interrupt-parent: phandle for the interrupt gpio controller
+- interrupts: GPIO interrupt to which the chip is connected
+- enable-gpios: Output GPIO pin used for enabling/disabling the chip
+- firmware-gpios: Output GPIO pin used to enter firmware download mode
+
+Optional SoC Specific Properties:
+- pinctrl-names: Contains only one value - "default".
+- pintctrl-0: Specifies the pin control groups used for this controlle=
r.
+
+Example (for ARM-based BeagleBone with NPC100 NFC controller on I2C2):
+
+&i2c2 {
+
+	status =3D "okay";
+
+	npc100: npc100@29 {
+
+		compatible =3D "nxp,nxp-nci-i2c";
+
+		reg =3D <0x29>;
+		clock-frequency =3D <100000>;
+
+		interrupt-parent =3D <&gpio1>;
+		interrupts =3D <29 GPIO_ACTIVE_HIGH>;
+
+		enable-gpios =3D <&gpio0 30 GPIO_ACTIVE_HIGH>;
+		firmware-gpios =3D <&gpio0 31 GPIO_ACTIVE_HIGH>;
+	};
+};
diff --git a/drivers/nfc/nxp-nci/Kconfig b/drivers/nfc/nxp-nci/Kconfig
index 5107edd..ac54016 100644
--- a/drivers/nfc/nxp-nci/Kconfig
+++ b/drivers/nfc/nxp-nci/Kconfig
@@ -10,3 +10,15 @@ config NFC_NXP_NCI
 	  To compile this driver as a module, choose m here. The module will
 	  be called nxp_nci.
 	  Say N if unsure.
+
+config NFC_NXP_NCI_I2C
+	tristate "NXP-NCI I2C support"
+	depends on NFC_NXP_NCI && I2C
+	---help---
+	  This module adds support for an I2C interface to the NXP NCI
+	  chips.
+	  Select this if your platform is using the I2C bus.
+
+	  To compile this driver as a module, choose m here. The module will
+	  be called nxp_nci_i2c.
+	  Say Y if unsure.
diff --git a/drivers/nfc/nxp-nci/Makefile b/drivers/nfc/nxp-nci/Makefil=
e
index 8f1e328..c008be3 100644
--- a/drivers/nfc/nxp-nci/Makefile
+++ b/drivers/nfc/nxp-nci/Makefile
@@ -3,7 +3,9 @@
 #
=20
 nxp-nci-objs =3D core.o firmware.o
+nxp-nci_i2c-objs =3D i2c.o
=20
 obj-$(CONFIG_NFC_NXP_NCI) +=3D nxp-nci.o
+obj-$(CONFIG_NFC_NXP_NCI_I2C) +=3D nxp-nci_i2c.o
=20
 ccflags-$(CONFIG_NFC_DEBUG) :=3D -DDEBUG
diff --git a/drivers/nfc/nxp-nci/i2c.c b/drivers/nfc/nxp-nci/i2c.c
new file mode 100644
index 0000000..4d6293b
--- /dev/null
+++ b/drivers/nfc/nxp-nci/i2c.c
@@ -0,0 +1,468 @@
+/*
+ * I2C link layer for the NXP NCI driver
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
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/delay.h>
+#include <linux/i2c.h>
+#include <linux/interrupt.h>
+#include <linux/miscdevice.h>
+#include <linux/module.h>
+#include <linux/nfc.h>
+#include <linux/of_gpio.h>
+#include <linux/of_irq.h>
+#include <linux/platform_data/nxp-nci.h>
+#include <linux/unaligned/access_ok.h>
+
+#include <net/nfc/nfc.h>
+
+#include "nxp-nci.h"
+
+#define NXP_NCI_I2C_DRIVER_NAME	"nxp-nci_i2c"
+
+#define NXP_NCI_I2C_MAX_PAYLOAD	32
+
+struct nxp_nci_i2c_phy {
+	struct i2c_client *i2c_dev;
+	struct nci_dev *ndev;
+
+	unsigned int gpio_en;
+	unsigned int gpio_fw;
+
+	int hard_fault; /*
+			 * < 0 if hardware error occurred (e.g. i2c err)
+			 * and prevents normal operation.
+			 */
+};
+
+static void nxp_nci_i2c_enable_mode(struct nxp_nci_i2c_phy *phy,
+				    enum nxp_nci_mode mode)
+{
+	gpio_set_value(phy->gpio_fw, (mode =3D=3D NXP_NCI_MODE_FW) ? 1 : 0);
+	gpio_set_value(phy->gpio_en, (mode !=3D NXP_NCI_MODE_COLD) ? 1 : 0);
+	usleep_range(10000, 15000);
+}
+
+int nxp_nci_i2c_enable(void *phy_id)
+{
+	nxp_nci_i2c_enable_mode((struct nxp_nci_i2c_phy *) phy_id,
+				NXP_NCI_MODE_NCI);
+	return 0;
+}
+
+int nxp_nci_i2c_fw_enable(void *phy_id)
+{
+	nxp_nci_i2c_enable_mode((struct nxp_nci_i2c_phy *) phy_id,
+				NXP_NCI_MODE_FW);
+	return 0;
+}
+
+int nxp_nci_i2c_disable(void *phy_id)
+{
+	struct nxp_nci_i2c_phy *phy =3D phy_id;
+
+	nxp_nci_i2c_enable_mode(phy, NXP_NCI_MODE_COLD);
+	phy->hard_fault =3D 0;
+
+	return 0;
+}
+
+static int nxp_nci_i2c_write(void *phy_id, struct sk_buff *skb)
+{
+	int r;
+	struct nxp_nci_i2c_phy *phy =3D phy_id;
+	struct i2c_client *client =3D phy->i2c_dev;
+
+	if (phy->hard_fault !=3D 0)
+		return phy->hard_fault;
+
+	r =3D i2c_master_send(client, skb->data, skb->len);
+	if (r =3D=3D -EREMOTEIO) {
+		/* Retry, chip was in standby */
+		usleep_range(110000, 120000);
+		r =3D i2c_master_send(client, skb->data, skb->len);
+	}
+
+	if (r < 0) {
+		nfc_err(&client->dev, "Error %d on I2C send\n", r);
+	} else if (r !=3D skb->len) {
+		nfc_err(&client->dev,
+			"Invalid length sent: %u (expected %u)\n",
+			r, skb->len);
+		r =3D -EREMOTEIO;
+	} else {
+		/* Success but return 0 and not number of bytes */
+		r =3D 0;
+	}
+
+	return r;
+}
+
+static struct nxp_nci_phy_ops i2c_phy_ops =3D {
+	.enable =3D nxp_nci_i2c_enable,
+	.fw_enable =3D nxp_nci_i2c_fw_enable,
+	.disable =3D nxp_nci_i2c_disable,
+	.write =3D nxp_nci_i2c_write,
+};
+
+static int nxp_nci_i2c_fw_read(struct nxp_nci_i2c_phy *phy,
+			       struct sk_buff **skb)
+{
+	struct i2c_client *client =3D phy->i2c_dev;
+	u16 header;
+	size_t frame_len;
+	int r;
+
+	r =3D i2c_master_recv(client, (u8 *) &header, NXP_NCI_FW_HDR_LEN);
+	if (r < 0) {
+		goto fw_read_exit;
+	} else if (r !=3D NXP_NCI_FW_HDR_LEN) {
+		nfc_err(&client->dev, "Incorrect header length: %u\n", r);
+		r =3D -EBADMSG;
+		goto fw_read_exit;
+	}
+
+	frame_len =3D (get_unaligned_be16(&header) & NXP_NCI_FW_FRAME_LEN_MAS=
K) +
+		    NXP_NCI_FW_CRC_LEN;
+
+	*skb =3D alloc_skb(NXP_NCI_FW_HDR_LEN + frame_len, GFP_KERNEL);
+	if (*skb =3D=3D NULL) {
+		r =3D -ENOMEM;
+		goto fw_read_exit;
+	}
+
+	memcpy(skb_put(*skb, NXP_NCI_FW_HDR_LEN), &header, NXP_NCI_FW_HDR_LEN=
);
+
+	r =3D i2c_master_recv(client, skb_put(*skb, frame_len), frame_len);
+	if (r !=3D frame_len) {
+		nfc_err(&client->dev,
+			"Invalid frame length: %u (expected %u)\n",
+			r, frame_len);
+		r =3D -EBADMSG;
+		goto fw_read_exit_free_skb;
+	}
+
+	r =3D 0;
+	goto fw_read_exit;
+
+fw_read_exit_free_skb:
+	kfree_skb(*skb);
+fw_read_exit:
+	return r;
+}
+
+static int nxp_nci_i2c_nci_read(struct nxp_nci_i2c_phy *phy,
+				struct sk_buff **skb)
+{
+	struct nci_ctrl_hdr header; /* May actually be a data header */
+	struct i2c_client *client =3D phy->i2c_dev;
+	int r;
+
+	r =3D i2c_master_recv(client, (u8 *) &header, NCI_CTRL_HDR_SIZE);
+	if (r < 0) {
+		goto nci_read_exit;
+	} else if (r !=3D NCI_CTRL_HDR_SIZE) {
+		nfc_err(&client->dev, "Incorrect header length: %u\n", r);
+		r =3D -EBADMSG;
+		goto nci_read_exit;
+	}
+
+	*skb =3D alloc_skb(NCI_CTRL_HDR_SIZE + header.plen, GFP_KERNEL);
+	if (*skb =3D=3D NULL) {
+		r =3D -ENOMEM;
+		goto nci_read_exit;
+	}
+
+	memcpy(skb_put(*skb, NCI_CTRL_HDR_SIZE), (void *) &header,
+	       NCI_CTRL_HDR_SIZE);
+
+	r =3D i2c_master_recv(client, skb_put(*skb, header.plen), header.plen=
);
+	if (r !=3D header.plen) {
+		nfc_err(&client->dev,
+			"Invalid frame payload length: %u (expected %u)\n",
+			r, header.plen);
+		r =3D -EBADMSG;
+		goto nci_read_exit_free_skb;
+	}
+
+	r =3D 0;
+	goto nci_read_exit;
+
+nci_read_exit_free_skb:
+	kfree_skb(*skb);
+nci_read_exit:
+	return r;
+}
+
+static irqreturn_t nxp_nci_i2c_irq_thread_fn(int irq, void *phy_id)
+{
+	struct nxp_nci_i2c_phy *phy =3D phy_id;
+	struct i2c_client *client;
+	struct nxp_nci_info *info;
+
+	struct sk_buff *skb =3D NULL;
+	int r =3D 0;
+
+	if (!phy || !phy->ndev)
+		goto exit_irq_none;
+
+	client =3D phy->i2c_dev;
+
+	if (!client || irq !=3D client->irq)
+		goto exit_irq_none;
+
+	if (phy->hard_fault !=3D 0)
+		goto exit_irq_handled;
+
+	info =3D nci_get_drvdata(phy->ndev);
+
+	switch (info->mode) {
+	case NXP_NCI_MODE_NCI:
+		r =3D nxp_nci_i2c_nci_read(phy, &skb);
+		break;
+	case NXP_NCI_MODE_FW:
+		r =3D nxp_nci_i2c_fw_read(phy, &skb);
+		break;
+	case NXP_NCI_MODE_COLD:
+		r =3D -EREMOTEIO;
+		break;
+	}
+
+	if (r =3D=3D -EREMOTEIO) {
+		phy->hard_fault =3D r;
+		skb =3D NULL;
+	} else if (r < 0) {
+		nfc_err(&client->dev, "Read failed with error %d\n", r);
+		goto exit_irq_handled;
+	}
+
+	switch (info->mode) {
+	case NXP_NCI_MODE_NCI:
+		nci_recv_frame(phy->ndev, skb);
+		break;
+	case NXP_NCI_MODE_FW:
+		nxp_nci_fw_recv_frame(phy->ndev, skb);
+		break;
+	case NXP_NCI_MODE_COLD:
+		break;
+	}
+
+exit_irq_handled:
+	return IRQ_HANDLED;
+exit_irq_none:
+	WARN_ON_ONCE(1);
+	return IRQ_NONE;
+}
+
+#ifdef CONFIG_OF
+
+static int nxp_nci_i2c_parse_devtree(struct i2c_client *client)
+{
+	struct nxp_nci_i2c_phy *phy =3D i2c_get_clientdata(client);
+	struct device_node *pp;
+	int r;
+
+	pp =3D client->dev.of_node;
+	if (!pp)
+		return -ENODEV;
+
+	r =3D of_get_named_gpio(pp, "enable-gpios", 0);
+	if (r =3D=3D -EPROBE_DEFER)
+		r =3D of_get_named_gpio(pp, "enable-gpios", 0);
+	if (r < 0) {
+		nfc_err(&client->dev, "Failed to get EN gpio, error: %d\n", r);
+		return r;
+	}
+	phy->gpio_en =3D r;
+
+	r =3D of_get_named_gpio(pp, "firmware-gpios", 0);
+	if (r =3D=3D -EPROBE_DEFER)
+		r =3D of_get_named_gpio(pp, "firmware-gpios", 0);
+	if (r < 0) {
+		nfc_err(&client->dev, "Failed to get FW gpio, error: %d\n", r);
+		return r;
+	}
+	phy->gpio_fw =3D r;
+
+	r =3D irq_of_parse_and_map(pp, 0);
+	if (r < 0) {
+		nfc_err(&client->dev, "Unable to get irq, error: %d\n", r);
+		return r;
+	}
+	client->irq =3D r;
+
+	return 0;
+}
+
+#else
+
+static int nxp_nci_i2c_parse_devtree(struct i2c_client *client)
+{
+	return -ENODEV;
+}
+
+#endif
+
+static int nxp_nci_i2c_request_gpios(struct nxp_nci_i2c_phy *phy)
+{
+	int r;
+
+	r =3D gpio_request(phy->gpio_en, "nxp_nci_en");
+	if (r < 0)
+		goto err_out;
+
+	r =3D gpio_direction_output(phy->gpio_en, 0);
+	if (r < 0)
+		goto err_gpio_en;
+
+	r =3D gpio_request(phy->gpio_fw, "nxp_nci_fw");
+	if (r < 0)
+		goto err_gpio_en;
+
+	r =3D gpio_direction_output(phy->gpio_fw, 0);
+	if (r < 0)
+		goto err_gpio_fw;
+
+	goto err_out;
+
+err_gpio_fw:
+	gpio_free(phy->gpio_fw);
+err_gpio_en:
+	gpio_free(phy->gpio_en);
+err_out:
+	return r;
+}
+
+static void nxp_nci_i2c_free_gpios(struct nxp_nci_i2c_phy *phy)
+{
+	gpio_free(phy->gpio_fw);
+	gpio_free(phy->gpio_en);
+}
+
+static int nxp_nci_i2c_probe(struct i2c_client *client,
+			    const struct i2c_device_id *id)
+{
+	struct nxp_nci_i2c_phy *phy;
+	struct nxp_nci_nfc_platform_data *pdata;
+	int r;
+
+	if (!i2c_check_functionality(client->adapter, I2C_FUNC_I2C)) {
+		nfc_err(&client->dev, "Need I2C_FUNC_I2C\n");
+		r =3D -ENODEV;
+		goto probe_exit;
+	}
+
+	phy =3D devm_kzalloc(&client->dev, sizeof(struct nxp_nci_i2c_phy),
+			   GFP_KERNEL);
+	if (!phy) {
+		r =3D -ENOMEM;
+		goto probe_exit;
+	}
+
+	phy->i2c_dev =3D client;
+	i2c_set_clientdata(client, phy);
+
+	pdata =3D client->dev.platform_data;
+
+	if (!pdata && client->dev.of_node) {
+		r =3D nxp_nci_i2c_parse_devtree(client);
+		if (r < 0) {
+			nfc_err(&client->dev, "Failed to get DT data\n");
+			goto probe_exit;
+		}
+	} else if (pdata) {
+		phy->gpio_en =3D pdata->gpio_en;
+		phy->gpio_fw =3D pdata->gpio_fw;
+		client->irq =3D pdata->irq;
+	} else {
+		nfc_err(&client->dev, "No platform data\n");
+		r =3D -EINVAL;
+		goto probe_exit;
+	}
+
+	r =3D nxp_nci_i2c_request_gpios(phy);
+	if (r < 0)
+		goto probe_exit;
+
+	r =3D nxp_nci_probe(phy, &client->dev, &i2c_phy_ops,
+			  NXP_NCI_I2C_MAX_PAYLOAD, &phy->ndev);
+	if (r < 0)
+		goto probe_exit_free_gpio;
+
+	r =3D request_threaded_irq(client->irq, NULL,
+				 nxp_nci_i2c_irq_thread_fn,
+				 IRQF_TRIGGER_RISING | IRQF_ONESHOT,
+				 NXP_NCI_I2C_DRIVER_NAME, phy);
+	if (r < 0) {
+		nfc_err(&client->dev, "Unable to register IRQ handler\n");
+		goto probe_exit_free_gpio;
+	}
+
+	goto probe_exit;
+
+probe_exit_free_gpio:
+	nxp_nci_i2c_free_gpios(phy);
+probe_exit:
+	return r;
+}
+
+static int nxp_nci_i2c_remove(struct i2c_client *client)
+{
+	struct nxp_nci_i2c_phy *phy =3D i2c_get_clientdata(client);
+
+	nxp_nci_remove(phy->ndev);
+
+	nxp_nci_i2c_free_gpios(phy);
+	free_irq(client->irq, phy);
+
+	return 0;
+}
+
+static struct i2c_device_id nxp_nci_i2c_id_table[] =3D {
+	{"nxp-nci_i2c", 0},
+	{}
+};
+MODULE_DEVICE_TABLE(i2c, nxp_nci_i2c_id_table);
+
+static const struct of_device_id of_nxp_nci_i2c_match[] =3D {
+	{ .compatible =3D "nxp,nxp-nci-i2c", },
+	{},
+};
+MODULE_DEVICE_TABLE(of, of_nxp_nci_i2c_match);
+
+static struct i2c_driver nxp_nci_i2c_driver =3D {
+	.driver =3D {
+		   .name =3D NXP_NCI_I2C_DRIVER_NAME,
+		   .owner  =3D THIS_MODULE,
+		   .of_match_table =3D of_match_ptr(of_nxp_nci_i2c_match),
+		  },
+	.probe =3D nxp_nci_i2c_probe,
+	.id_table =3D nxp_nci_i2c_id_table,
+	.remove =3D nxp_nci_i2c_remove,
+};
+
+module_i2c_driver(nxp_nci_i2c_driver);
+
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("I2C driver for NXP NCI NFC controllers");
+MODULE_AUTHOR("Cl=C3=A9ment Perrochaud <clement.perrochaud-3arQi8VN3Tc@public.gmane.org>");
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
To unsubscribe from this list: send the line "unsubscribe devicetree" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
