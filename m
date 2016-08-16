From: Colin King <colin.king@canonical.com>
Subject: [PATCH] mwifiex: fix missing break on IEEE80211_STYPE_ACTION case
Date: Tue, 16 Aug 2016 13:10:13 +0100
Message-ID: <1471349413-21893-1-git-send-email-colin.king@canonical.com>
Cc: linux-kernel@vger.kernel.org
To: Amitkumar Karwar <akarwar@marvell.com>,
	Nishant Sarmukadam <nishants@marvell.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The IEEE80211_STYPE_ACTION case is missing a break in the switch
statement, causing it to fall through to the default case that
reports a debug message about an unknown frame subtype. Fix this
by adding in the missing break statement.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/wireless/marvell/mwifiex/util.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/wireless/marvell/mwifiex/util.c b/drivers/net/wireless/marvell/mwifiex/util.c
index 6681be0..18fbb96 100644
--- a/drivers/net/wireless/marvell/mwifiex/util.c
+++ b/drivers/net/wireless/marvell/mwifiex/util.c
@@ -386,6 +386,7 @@ mwifiex_parse_mgmt_packet(struct mwifiex_private *priv, u8 *payload, u16 len,
 				    "unknown public action frame category %d\n",
 				    category);
 		}
+		break;
 	default:
 		mwifiex_dbg(priv->adapter, INFO,
 		    "unknown mgmt frame subtype %#x\n", stype);
-- 
2.8.1
