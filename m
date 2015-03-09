From: clement.perrochaud@effinnov.com
Subject: [PATCH v2 1/3] NFC: nci: Add firmware download support
Date: Mon,  9 Mar 2015 11:12:03 +0100
Message-ID: <1425895925-20593-2-git-send-email-clement.perrochaud@effinnov.com>
References: <1425895925-20593-1-git-send-email-clement.perrochaud@effinnov.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Cl=C3=A9ment=20Perrochaud?= <clement.perrochaud@nxp.com>,
	sunil.jogi@nxp.com, jerome.pele@nxp.com,
	Charles.Gorand-Effinnov@nxp.com, lauro.venancio@openbossa.org,
	aloisio.almeida@openbossa.org, sameo@linux.intel.com,
	robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	davem@davemloft.net, grant.likely@linaro.org, lefrique@marvell.com,
	christophe.ricard@gmail.com, cuissard@marvell.com,
	bzhao@marvell.com, hirent@marvell.com, akarwar@marvell.com,
	linux-wireless@vger.kernel.org, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	anda-maria.nicolae@intel.com,
	=?UTF-8?q?Cl=C3=A9ment=20Perrochaud?=
	<clement.perrochaud@effinnov.com>
To: linux-nfc@lists.01.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425895925-20593-1-git-send-email-clement.perrochaud@effinnov.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Cl=C3=A9ment Perrochaud <clement.perrochaud@nxp.com>

A simple forward for firmware download (i.e. sending a new firmware
to the NFC adapter) from the NFC subsystem to the drivers.

This feature is required to update the firmware of NXP-NCI NFC
controllers but can be used by any NCI driver.

This feature has been present in the HCI subsystem since 9a695d.

Signed-off-by: Cl=C3=A9ment Perrochaud <clement.perrochaud@effinnov.com=
>
---
 include/net/nfc/nci_core.h |  1 +
 net/nfc/nci/core.c         | 11 +++++++++++
 2 files changed, 12 insertions(+)

diff --git a/include/net/nfc/nci_core.h b/include/net/nfc/nci_core.h
index ff87f86..34a6e09 100644
--- a/include/net/nfc/nci_core.h
+++ b/include/net/nfc/nci_core.h
@@ -71,6 +71,7 @@ struct nci_ops {
 	int   (*close)(struct nci_dev *ndev);
 	int   (*send)(struct nci_dev *ndev, struct sk_buff *skb);
 	int   (*setup)(struct nci_dev *ndev);
+	int   (*fw_download)(struct nci_dev *ndev, const char *firmware_name)=
;
 	__u32 (*get_rfprotocol)(struct nci_dev *ndev, __u8 rf_protocol);
 	int   (*discover_se)(struct nci_dev *ndev);
 	int   (*disable_se)(struct nci_dev *ndev, u32 se_idx);
diff --git a/net/nfc/nci/core.c b/net/nfc/nci/core.c
index 9575a18..49ff321 100644
--- a/net/nfc/nci/core.c
+++ b/net/nfc/nci/core.c
@@ -907,6 +907,16 @@ static int nci_se_io(struct nfc_dev *nfc_dev, u32 =
se_idx,
 	return 0;
 }
=20
+static int nci_fw_download(struct nfc_dev *nfc_dev, const char *firmwa=
re_name)
+{
+	struct nci_dev *ndev =3D nfc_get_drvdata(nfc_dev);
+
+	if (!ndev->ops->fw_download)
+		return -ENOTSUPP;
+
+	return ndev->ops->fw_download(ndev, firmware_name);
+}
+
 static struct nfc_ops nci_nfc_ops =3D {
 	.dev_up =3D nci_dev_up,
 	.dev_down =3D nci_dev_down,
@@ -922,6 +932,7 @@ static struct nfc_ops nci_nfc_ops =3D {
 	.disable_se =3D nci_disable_se,
 	.discover_se =3D nci_discover_se,
 	.se_io =3D nci_se_io,
+	.fw_download =3D nci_fw_download,
 };
=20
 /* ---- Interface to NCI drivers ---- */
--=20
Cl=C3=A9ment Perrochaud

Eff'Innov Technologies
Caen, Aix-En-Provence, Grenoble

Eff'Innov Technologies
Campus EffiScience
2, Esplanade Anton Philips
14460 Colombelles, FRANCE

http://www.effinnov.com
