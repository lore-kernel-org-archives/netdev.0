From: "Justin P. Mattock" <justinmattock@gmail.com>
Subject: [PATCH 1/5 v2]wireless:hostap_main.c warning: variable 'iface' set but not used
Date: Mon, 21 Jun 2010 15:02:13 -0700
Message-ID: <1277157733-14071-1-git-send-email-justinmattock@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Justin P. Mattock" <justinmattock@gmail.com>
To: linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a resend from version one due to trying a different approach
than the original(probably important to leave netdev_priv() in).

In any case have a look, if there's another approach let me know
and ill test it out. The below patch fixes a warning im seeing
when compiling with gcc 4.6.0

CC [M]  drivers/net/wireless/hostap/hostap_main.o
drivers/net/wireless/hostap/hostap_main.c: In function 'hostap_set_multicast_list_queue':
drivers/net/wireless/hostap/hostap_main.c:744:27: warning: variable 'iface' set but not used
 Signed-off-by: Justin P. Mattock <justinmattock@gmail.com>

---
 drivers/net/wireless/hostap/hostap_main.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/hostap/hostap_main.c b/drivers/net/wireless/hostap/hostap_main.c
index eb57d1e..a866e7a 100644
--- a/drivers/net/wireless/hostap/hostap_main.c
+++ b/drivers/net/wireless/hostap/hostap_main.c
@@ -741,9 +741,8 @@ void hostap_set_multicast_list_queue(struct work_struct *work)
 	local_info_t *local =
 		container_of(work, local_info_t, set_multicast_list_queue);
 	struct net_device *dev = local->dev;
-	struct hostap_interface *iface;
 
-	iface = netdev_priv(dev);
+	netdev_priv(dev);
 	if (hostap_set_word(dev, HFA384X_RID_PROMISCUOUSMODE,
 			    local->is_promisc)) {
 		printk(KERN_INFO "%s: %sabling promiscuous mode failed\n",
-- 
1.7.1.rc1.21.gf3bd6
