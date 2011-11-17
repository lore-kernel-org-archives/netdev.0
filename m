From: Thomas Meyer <thomas@m3y3r.de>
Subject: [PATCH] brcm80211: smac: Use kmemdup rather than duplicating its
 implementation
Date: Thu, 17 Nov 2011 23:43:40 +0100
Message-ID: <1321569820.1624.289.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The semantic patch that makes this change is available
in scripts/coccinelle/api/memdup.cocci.

Signed-off-by: Thomas Meyer <thomas@m3y3r.de>
---

diff -u -p a/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c b/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
--- a/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c 2011-11-07 19:39:05.641131954 +0100
+++ b/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c 2011-11-08 10:44:56.761349456 +0100
@@ -1561,11 +1561,10 @@ int brcms_ucode_init_buf(struct brcms_in
 			if (le32_to_cpu(hdr->idx) == idx) {
 				pdata = wl->fw.fw_bin[i]->data +
 					le32_to_cpu(hdr->offset);
-				*pbuf = kmalloc(len, GFP_ATOMIC);
+				*pbuf = kmemdup(pdata, len, GFP_ATOMIC);
 				if (*pbuf == NULL)
 					goto fail;
 
-				memcpy(*pbuf, pdata, len);
 				return 0;
 			}
 		}
