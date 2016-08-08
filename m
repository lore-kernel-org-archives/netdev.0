From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: [PATCH 1/2] mwifiex: fix the length parameter of a memset
Date: Mon,  8 Aug 2016 09:38:48 +0200
Message-ID: <1470641928-26616-1-git-send-email-christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org,
	Christophe JAILLET <christophe.jaillet@wanadoo.fr>
To: akarwar@marvell.com, nishants@marvell.com,
	linux-wireless@vger.kernel.org
Return-path: <kernel-janitors-owner@vger.kernel.org>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In 'mwifiex_get_ver_ext', we have:
   struct mwifiex_ver_ext ver_ext;

   memset(&ver_ext, 0, sizeof(struct host_cmd_ds_version_ext));

This is likely that memset'ing sizeof(struct mwifiex_ver_ext) was expected.
Remove the ambiguity by using the variable name directly instead of its
type.

Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
---
 drivers/net/wireless/marvell/mwifiex/sta_ioctl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/marvell/mwifiex/sta_ioctl.c b/drivers/net/wireless/marvell/mwifiex/sta_ioctl.c
index e06647a..78819e8 100644
--- a/drivers/net/wireless/marvell/mwifiex/sta_ioctl.c
+++ b/drivers/net/wireless/marvell/mwifiex/sta_ioctl.c
@@ -1180,7 +1180,7 @@ mwifiex_get_ver_ext(struct mwifiex_private *priv, u32 version_str_sel)
 {
 	struct mwifiex_ver_ext ver_ext;
 
-	memset(&ver_ext, 0, sizeof(struct host_cmd_ds_version_ext));
+	memset(&ver_ext, 0, sizeof(ver_ext));
 	ver_ext.version_str_sel = version_str_sel;
 	if (mwifiex_send_cmd(priv, HostCmd_CMD_VERSION_EXT,
 			     HostCmd_ACT_GEN_GET, 0, &ver_ext, true))
-- 
2.7.4


---
L'absence de virus dans ce courrier électronique a été vérifiée par le logiciel antivirus Avast.
https://www.avast.com/antivirus

