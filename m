From: clement.perrochaud-BPEPtVrvniRWk0Htik3J/w@public.gmane.org
Subject: [PATCH 4/4] NFC: nxp-nci: Allow module removal during download
Date: Thu, 22 Jan 2015 16:27:40 +0100
Message-ID: <1421940460-14049-5-git-send-email-clement.perrochaud@effinnov.com>
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
 drivers/nfc/nxp-nci/core.c     | 7 +++----
 drivers/nfc/nxp-nci/firmware.c | 9 ++++++---
 2 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/nfc/nxp-nci/core.c b/drivers/nfc/nxp-nci/core.c
index d3643ef..c15606d 100644
--- a/drivers/nfc/nxp-nci/core.c
+++ b/drivers/nfc/nxp-nci/core.c
@@ -165,12 +165,11 @@ void nxp_nci_remove(struct nci_dev *ndev)
 {
 	struct nxp_nci_info *info =3D nci_get_drvdata(ndev);
=20
-	mutex_lock(&info->info_lock);
-
-	cancel_work_sync(&info->fw_info.work);
-
 	if (info->mode =3D=3D NXP_NCI_MODE_FW)
 		nxp_nci_fw_work_complete(info, -ESHUTDOWN);
+	cancel_work_sync(&info->fw_info.work);
+
+	mutex_lock(&info->info_lock);
=20
 	if (info->phy_ops->disable)
 		info->phy_ops->disable(info->phy_id);
diff --git a/drivers/nfc/nxp-nci/firmware.c b/drivers/nfc/nxp-nci/firmw=
are.c
index 1814e9f..de136e1 100644
--- a/drivers/nfc/nxp-nci/firmware.c
+++ b/drivers/nfc/nxp-nci/firmware.c
@@ -166,7 +166,8 @@ static int nxp_nci_fw_send(struct nxp_nci_info *inf=
o)
=20
 	if (*fw_info->data =3D=3D NXP_NCI_FW_CMD_RESET) {
 		fw_info->cmd_result =3D 0;
-		schedule_work(&fw_info->work);
+		if (fw_info->fw)
+			schedule_work(&fw_info->work);
 	} else {
 		completion_rc =3D wait_for_completion_interruptible_timeout(
 			&fw_info->cmd_completion, NXP_NCI_FW_ANSWER_TIMEOUT);
@@ -244,7 +245,8 @@ int nxp_nci_fw_download(struct nci_dev *ndev, const=
 char *firmware_name)
 	fw_info->frame_size =3D 0;
 	fw_info->cmd_result =3D 0;
=20
-	schedule_work(&fw_info->work);
+	if (fw_info->fw)
+		schedule_work(&fw_info->work);
=20
 fw_download_exit:
 	mutex_unlock(&info->info_lock);
@@ -316,6 +318,7 @@ void nxp_nci_fw_recv_frame(struct nci_dev *ndev, st=
ruct sk_buff *skb)
 		fw_info->cmd_result =3D -EIO;
 	}
=20
-	schedule_work(&fw_info->work);
+	if (fw_info->fw)
+		schedule_work(&fw_info->work);
 }
 EXPORT_SYMBOL(nxp_nci_fw_recv_frame);
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
