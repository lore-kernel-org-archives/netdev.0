From: Stefano Brivio <sbrivio-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net] intersil/hostap: Fix outdated comment about dev->destructor
Date: Thu, 27 Jul 2017 13:20:15 +0200
Message-ID: <0824ed85fd45846da65fc919ae22df9d7ebf2f97.1501150507.git.sbrivio@redhat.com>
Cc: "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, Jouni Malinen <j@w1.fi>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

After commit cf124db566e6 ("net: Fix inconsistent teardown and
release of private netdev state."), setting
'dev->needs_free_netdev' ensures device data is released, and
'dev->destructor' is not used anymore.

Fixes: cf124db566e6 ("net: Fix inconsistent teardown and release of private netdev state.")
Signed-off-by: Stefano Brivio <sbrivio-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
Despite checkpatch.pl warning against unnecessary changes, this
outdated comment might lead to confusion -- making this change
actually necessary, perhaps.

 drivers/net/wireless/intersil/hostap/hostap_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/intersil/hostap/hostap_main.c b/drivers/net/wireless/intersil/hostap/hostap_main.c
index a3c066f90afc..012930d35434 100644
--- a/drivers/net/wireless/intersil/hostap/hostap_main.c
+++ b/drivers/net/wireless/intersil/hostap/hostap_main.c
@@ -125,8 +125,8 @@ void hostap_remove_interface(struct net_device *dev, int rtnl_locked,
 	else
 		unregister_netdev(dev);
 
-	/* dev->destructor = free_netdev() will free the device data, including
-	 * private data, when removing the device */
+	/* 'dev->needs_free_netdev = true' implies device data, including
+	 * private data, will be freed when the device is removed */
 }
 
 
-- 
2.9.4
