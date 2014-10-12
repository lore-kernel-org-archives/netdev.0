From: Rickard Strandqvist <rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org>
Subject: [PATCH v2] brcmfmac: dhd_sdio.c:  Cleaning up missing null-terminate in conjunction with strncpy
Date: Sun, 12 Oct 2014 13:42:14 +0200
Message-ID: <1413114134-18044-2-git-send-email-rickard_strandqvist@spectrumdigital.se>
References: <1413114134-18044-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Cc: Rickard Strandqvist <rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org>,
	Hante Meuleman <meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Pieter-Paul Giesberts <pieterpg-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Daniel Kim <dekim-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Brett Rudley <brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1413114134-18044-1-git-send-email-rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Replacing strncpy with strlcpy to avoid strings that lacks null terminate.
And changed from using strncat to strlcat to simplify code.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org>
---
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |   25 ++++++++++----------
 1 file changed, 12 insertions(+), 13 deletions(-)

diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c b/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
index f55f625..d20d4e6 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
@@ -670,7 +670,6 @@ static int brcmf_sdio_get_fwnames(struct brcmf_chip *ci,
 				  struct brcmf_sdio_dev *sdiodev)
 {
 	int i;
-	uint fw_len, nv_len;
 	char end;
 
 	for (i = 0; i < ARRAY_SIZE(brcmf_fwname_data); i++) {
@@ -684,25 +683,25 @@ static int brcmf_sdio_get_fwnames(struct brcmf_chip *ci,
 		return -ENODEV;
 	}
 
-	fw_len = sizeof(sdiodev->fw_name) - 1;
-	nv_len = sizeof(sdiodev->nvram_name) - 1;
 	/* check if firmware path is provided by module parameter */
 	if (brcmf_firmware_path[0] != '\0') {
-		strncpy(sdiodev->fw_name, brcmf_firmware_path, fw_len);
-		strncpy(sdiodev->nvram_name, brcmf_firmware_path, nv_len);
-		fw_len -= strlen(sdiodev->fw_name);
-		nv_len -= strlen(sdiodev->nvram_name);
+		strlcpy(sdiodev->fw_name, brcmf_firmware_path,
+			sizeof(sdiodev->fw_name));
+		strlcpy(sdiodev->nvram_name, brcmf_firmware_path,
+			sizeof(sdiodev->nvram_name));
 
 		end = brcmf_firmware_path[strlen(brcmf_firmware_path) - 1];
 		if (end != '/') {
-			strncat(sdiodev->fw_name, "/", fw_len);
-			strncat(sdiodev->nvram_name, "/", nv_len);
-			fw_len--;
-			nv_len--;
+			strlcat(sdiodev->fw_name, "/",
+				sizeof(sdiodev->fw_name));
+			strlcat(sdiodev->nvram_name, "/",
+				sizeof(sdiodev->nvram_name));
 		}
 	}
-	strncat(sdiodev->fw_name, brcmf_fwname_data[i].bin, fw_len);
-	strncat(sdiodev->nvram_name, brcmf_fwname_data[i].nv, nv_len);
+	strlcat(sdiodev->fw_name, brcmf_fwname_data[i].bin,
+		sizeof(sdiodev->fw_name));
+	strlcat(sdiodev->nvram_name, brcmf_fwname_data[i].nv,
+		sizeof(sdiodev->nvram_name));
 
 	return 0;
 }
-- 
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
