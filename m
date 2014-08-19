From: "Sharma, Sanjeev" <Sanjeev_Sharma-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>
Subject: RE: [PATCH] zd1211rw: replace ZD_ASSERT with lockdep_assert_held()
Date: Tue, 19 Aug 2014 06:39:29 +0000
Message-ID: <FDC088D3B5555644AE135ED28A7ABDE94DF2FDC2@EU-MBX-02.mgc.mentorg.com>
References: <1407827133-29493-1-git-send-email-sanjeev_sharma@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Sharma, Sanjeev" <Sanjeev_Sharma-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>,
	"dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org" <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>,
	"kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org" <kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1407827133-29493-1-git-send-email-sanjeev_sharma-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>
Content-Language: en-US
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Ping for review the patch.

thanks,

Sanjeev Sharma
-----Original Message-----
From: Sanjeev Sharma [mailto:sanjeev_sharma-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org] 
Sent: Tuesday, August 12, 2014 12:36 PM
To: dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org; kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org; linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Sharma, Sanjeev; Sharma, Sanjeev
Subject: [PATCH] zd1211rw: replace ZD_ASSERT with lockdep_assert_held()

on some architecture spin_is_locked() always return false in uniprocessor configuration and therefore it would be advise to replace with lockdep_assert_held().

Signed-off-by: Sanjeev Sharma <Sanjeev_Sharma-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>
---
 drivers/net/wireless/zd1211rw/zd_mac.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c b/drivers/net/wireless/zd1211rw/zd_mac.c
index e7af261..72c0bc2 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -235,7 +235,7 @@ void zd_mac_clear(struct zd_mac *mac)  {
 	flush_workqueue(zd_workqueue);
 	zd_chip_clear(&mac->chip);
-	ZD_ASSERT(!spin_is_locked(&mac->lock));
+	lockdep_assert_held(!spin_is_locked(&mac->lock));
 	ZD_MEMCLEAR(mac, sizeof(struct zd_mac));  }
 
--
1.7.11.7

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
