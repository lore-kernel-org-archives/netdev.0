From: Erik Stromdahl <erik.stromdahl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] mac80211_hwsim: Added vendor echo command
Date: Fri, 24 Jun 2016 10:13:54 +0200
Message-ID: <1466756034-5485-1-git-send-email-erik.stromdahl@gmail.com>
Cc: Erik Stromdahl <erik.stromdahl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The purpose of the echo command is to provide a test
facility for user space programs.

Signed-off-by: Erik Stromdahl <erik.stromdahl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/wireless/mac80211_hwsim.c |   27 +++++++++++++++++++++++++--
 1 file changed, 25 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index 4dd5adc..2e17bf1 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -332,14 +332,16 @@ static const struct ieee80211_rate hwsim_rates[] = {
 
 #define OUI_QCA 0x001374
 #define QCA_NL80211_SUBCMD_TEST 1
+#define QCA_NL80211_SUBCMD_ECHO 2
 enum qca_nl80211_vendor_subcmds {
 	QCA_WLAN_VENDOR_ATTR_TEST = 8,
-	QCA_WLAN_VENDOR_ATTR_MAX = QCA_WLAN_VENDOR_ATTR_TEST
+	QCA_WLAN_VENDOR_ATTR_ECHO,
+	QCA_WLAN_VENDOR_ATTR_MAX = QCA_WLAN_VENDOR_ATTR_ECHO
 };
 
 static const struct nla_policy
 hwsim_vendor_test_policy[QCA_WLAN_VENDOR_ATTR_MAX + 1] = {
-	[QCA_WLAN_VENDOR_ATTR_MAX] = { .type = NLA_U32 },
+	[QCA_WLAN_VENDOR_ATTR_TEST] = { .type = NLA_U32 },
 };
 
 static int mac80211_hwsim_vendor_cmd_test(struct wiphy *wiphy,
@@ -393,12 +395,33 @@ static int mac80211_hwsim_vendor_cmd_test(struct wiphy *wiphy,
 	return cfg80211_vendor_cmd_reply(skb);
 }
 
+static int mac80211_hwsim_vendor_cmd_echo(struct wiphy *wiphy,
+					  struct wireless_dev *wdev,
+					  const void *data, int data_len)
+{
+	struct sk_buff *skb;
+
+	skb = cfg80211_vendor_cmd_alloc_reply_skb(wiphy, data_len);
+	if (!skb)
+		return -ENOMEM;
+
+	nla_put(skb, QCA_WLAN_VENDOR_ATTR_ECHO, data_len, data);
+
+	return cfg80211_vendor_cmd_reply(skb);
+}
+
 static struct wiphy_vendor_command mac80211_hwsim_vendor_commands[] = {
 	{
 		.info = { .vendor_id = OUI_QCA,
 			  .subcmd = QCA_NL80211_SUBCMD_TEST },
 		.flags = WIPHY_VENDOR_CMD_NEED_NETDEV,
 		.doit = mac80211_hwsim_vendor_cmd_test,
+	},
+	{
+		.info = { .vendor_id = OUI_QCA,
+			  .subcmd = QCA_NL80211_SUBCMD_ECHO },
+		.flags = WIPHY_VENDOR_CMD_NEED_NETDEV,
+		.doit = mac80211_hwsim_vendor_cmd_echo,
 	}
 };
 
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
