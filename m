From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH/RFC] deprecate print_mac
Date: Sat, 25 Oct 2008 02:09:55 +0200
Message-ID: <1224893395.3919.39.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:41633 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751131AbYJYAKC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2008 20:10:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Or more precisely, deprecate the variables that DECLARE_MAC_BUF
creates, DECLARE_MAC_BUF is required for print_mac and the latter
uses the created variables.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
---
I don't think we want this without the bulk of the users removed. And
after that, it should be removed before long anyway.

 include/linux/if_ether.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- everything.orig/include/linux/if_ether.h	2008-10-25 02:02:02.000000000 +0200
+++ everything/include/linux/if_ether.h	2008-10-25 02:05:08.000000000 +0200
@@ -133,12 +133,12 @@ extern struct ctl_table ether_table[];
 extern ssize_t sysfs_format_mac(char *buf, const unsigned char *addr, int len);
 
 /*
- *	Display a 6 byte device address (MAC) in a readable format.
+ * Use the %pM printf format specifier instead of this.
  */
 extern char *print_mac(char *buf, const unsigned char *addr);
 #define MAC_FMT "%02x:%02x:%02x:%02x:%02x:%02x"
 #define MAC_BUF_SIZE	18
-#define DECLARE_MAC_BUF(var) char var[MAC_BUF_SIZE] __maybe_unused
+#define DECLARE_MAC_BUF(var) char var[MAC_BUF_SIZE] __maybe_unused __deprecated
 
 #endif
 


