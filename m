From: Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2.6] SoftMAC : fix ESSID problem
Date: Mon, 9 Jul 2007 15:19:22 -0700
Message-ID: <20070709221922.GB1381@bougret.hpl.hp.com>
Reply-To: jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

	Hi,

	Victor Porton reported that the SoftMAC layer had random
problem when setting the ESSID :
		http://bugzilla.kernel.org/show_bug.cgi?id=8686
	After investigation, it turned out to be worse, the SoftMAC
layer is left in an inconsistent state. The fix is pretty trivial.
        John : would you mind pushing that to 2.6.23 ?
        Thanks...

        Jean

Signed-off-by: Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>

-----------------------------------------------------------

--- linux/net/ieee80211/softmac/ieee80211softmac_assoc.j1.c	2007-07-09 13:56:13.000000000 -0700
+++ linux/net/ieee80211/softmac/ieee80211softmac_assoc.c	2007-07-09 13:56:41.000000000 -0700
@@ -271,8 +271,11 @@ ieee80211softmac_assoc_work(struct work_
 			 */
 			dprintk(KERN_INFO PFX "Associate: Scanning for networks first.\n");
 			ieee80211softmac_notify(mac->dev, IEEE80211SOFTMAC_EVENT_SCAN_FINISHED, ieee80211softmac_assoc_notify_scan, NULL);
-			if (ieee80211softmac_start_scan(mac))
+			if (ieee80211softmac_start_scan(mac)) {
 				dprintk(KERN_INFO PFX "Associate: failed to initiate scan. Is device up?\n");
+				mac->associnfo.associating = 0;
+				mac->associnfo.associated = 0;
+			}
 			goto out;
 		} else {
 			mac->associnfo.associating = 0;
