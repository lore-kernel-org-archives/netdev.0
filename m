From: Rickard Strandqvist <rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org>
Subject: [PATCH] net: wireless: libertas: cmd.c:  Cleaning up uninitialized variables
Date: Sun,  1 Jun 2014 14:39:20 +0200
Message-ID: <1401626360-15505-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Cc: libertas-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Rickard Strandqvist <rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

There is a risk that the variable will be used without being initialized.

This was largely found by using a static code analysis program called cppcheck.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org>
---
 drivers/net/wireless/libertas/cmd.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/wireless/libertas/cmd.c b/drivers/net/wireless/libertas/cmd.c
index aaa2973..0387a5b 100644
--- a/drivers/net/wireless/libertas/cmd.c
+++ b/drivers/net/wireless/libertas/cmd.c
@@ -1111,6 +1111,7 @@ int lbs_set_radio(struct lbs_private *priv, u8 preamble, u8 radio_on)
 
 	cmd.hdr.size = cpu_to_le16(sizeof(cmd));
 	cmd.action = cpu_to_le16(CMD_ACT_SET);
+	cmd.control = 0;
 
 	/* Only v8 and below support setting the preamble */
 	if (priv->fwrelease < 0x09000000) {
-- 
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
