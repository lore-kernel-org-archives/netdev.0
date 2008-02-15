From: Bruno Randolf <bruno-L9ZBdB2wSWtl57MIdRCFDg@public.gmane.org>
Subject: [PATCH] add macro for printing mac addresses
Date: Fri, 15 Feb 2008 19:48:05 +0900
Message-ID: <20080215104804.9870.15722.stgit@one>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

is there any chance to include a macro like this for printing mac addresses?

its advantage is that it can be used without the need to declare buffers for
print_mac(), for example:

printk("mac address: " MAC_FMT, MAC_ADDR(addr));

Signed-off-by: Bruno Randolf <bruno-L9ZBdB2wSWtl57MIdRCFDg@public.gmane.org>
---

 include/linux/if_ether.h |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)


diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
index 5f92977..b9a6fb2 100644
--- a/include/linux/if_ether.h
+++ b/include/linux/if_ether.h
@@ -127,6 +127,15 @@ extern struct ctl_table ether_table[];
  *	Display a 6 byte device address (MAC) in a readable format.
  */
 #define MAC_FMT "%02x:%02x:%02x:%02x:%02x:%02x"
+
+#define MAC_ADDR(addr) \
+    ((unsigned char *)(addr))[0], \
+    ((unsigned char *)(addr))[1], \
+    ((unsigned char *)(addr))[2], \
+    ((unsigned char *)(addr))[3], \
+    ((unsigned char *)(addr))[4], \
+    ((unsigned char *)(addr))[5]
+
 extern char *print_mac(char *buf, const u8 *addr);
 #define DECLARE_MAC_BUF(var) char var[18] __maybe_unused
 
