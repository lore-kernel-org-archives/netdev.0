From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: PATCH to correct dump of WPA IE
Date: Thu, 08 Jun 2006 09:47:42 -0500
Message-ID: <4488388E.1080309@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:58263 "EHLO
	mtiwmhc11.worldnet.att.net") by vger.kernel.org with ESMTP
	id S964849AbWFHOrq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jun 2006 10:47:46 -0400
To: netdev@vger.kernel.org, John Linville <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In net/ieee80211/softmac/ieee80211softmac_wx.c, there is a bug that prints extended sign information 
whenever the byte value exceeds 0x7f. The following patch changes the printk to use a u8 cast to 
limit the output to 2 digits. This bug was first noticed by Dan Williams <dcbw@redhat.com>. This 
patch applies to the current master branch of the Linville tree.

Signed-Off-By: Larry Finger <Larry.Finger@lwfinger.net>


diff --git a/net/ieee80211/softmac/ieee80211softmac_wx.c b/net/ieee80211/softmac/ieee80211softmac_wx.c
index 27edb2b..55c5c26 100644
--- a/net/ieee80211/softmac/ieee80211softmac_wx.c
+++ b/net/ieee80211/softmac/ieee80211softmac_wx.c
@@ -388,7 +388,7 @@ ieee80211softmac_wx_set_genie(struct net
		memcpy(mac->wpa.IE, extra, wrqu->data.length);
		dprintk(KERN_INFO PFX "generic IE set to ");
		for (i=0;i<wrqu->data.length;i++)
-			dprintk("%.2x", mac->wpa.IE[i]);
+			dprintk("%.2x", (u8)mac->wpa.IE[i]);
		dprintk("\n");
		mac->wpa.IElen = wrqu->data.length;
	} else {
