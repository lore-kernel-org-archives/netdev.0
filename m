From: clement.perrochaud-BPEPtVrvniRWk0Htik3J/w@public.gmane.org
Subject: [PATCH 1/4] NFC: nci: Add FWDL support
Date: Thu, 22 Jan 2015 16:27:37 +0100
Message-ID: <1421940460-14049-2-git-send-email-clement.perrochaud@effinnov.com>
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
 include/net/nfc/nci_core.h |  1 +
 net/nfc/nci/core.c         | 11 +++++++++++
 2 files changed, 12 insertions(+)

diff --git a/include/net/nfc/nci_core.h b/include/net/nfc/nci_core.h
index 9e51bb4..137e059 100644
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
index 51feb5e..1342c7d 100644
--- a/net/nfc/nci/core.c
+++ b/net/nfc/nci/core.c
@@ -789,6 +789,16 @@ static int nci_se_io(struct nfc_dev *nfc_dev, u32 =
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
@@ -804,6 +814,7 @@ static struct nfc_ops nci_nfc_ops =3D {
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

--
To unsubscribe from this list: send the line "unsubscribe devicetree" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
