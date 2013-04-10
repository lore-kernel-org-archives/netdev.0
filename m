From: Martin Pitt <martin.pitt@ubuntu.com>
Subject: mac80211_hwsim: Check return value of driver_register
Date: Wed, 10 Apr 2013 18:40:27 +0200
Message-ID: <20130410164027.GB2884@piware.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Johannes Berg <johannes@sipsolutions.net>
To: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If driver_register() fails, properly exit with the same error code.

Signed-off-by: Martin Pitt <martin.pitt@ubuntu.com>
---
 drivers/net/wireless/mac80211_hwsim.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index 57361c3..a2224b7 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -2183,7 +2183,12 @@ static int __init init_mac80211_hwsim(void)
 	if (IS_ERR(hwsim_class))
 		return PTR_ERR(hwsim_class);
 
-	driver_register(&mac80211_hwsim_driver);
+	err = driver_register(&mac80211_hwsim_driver);
+	if (err != 0) {
+		printk(KERN_DEBUG
+		       "mac80211_hwsim: driver_register failed (%d)\n", err);
+		return err;
+	}
 
 	memset(addr, 0, ETH_ALEN);
 	addr[0] = 0x02;
-- 
1.7.2.5

-- 
Martin Pitt                        | http://www.piware.de
Ubuntu Developer (www.ubuntu.com)  | Debian Developer  (www.debian.org)
