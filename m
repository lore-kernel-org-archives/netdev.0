From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] net: deprecate print_mac
Date: Wed, 15 Jul 2009 17:23:23 +0200
Message-ID: <1247671403.10754.8.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:36722 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755490AbZGOPfu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2009 11:35:50 -0400
Received: by sipsolutions.net with esmtpsa (TLS1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.69)
	(envelope-from <johannes@sipsolutions.net>)
	id 1MR6WJ-0008Ov-JE
	for netdev@vger.kernel.org; Wed, 15 Jul 2009 17:35:48 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We've had %pM for long enough now, time to deprecate
print_mac() and remove the __maybe_unused attribute
from DECLARE_MAC_BUF so that variables declared with
that can be found and removed. Otherwise people are
putting in new users of print_mac().

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
---
On my tree, with three other patches I have submitted
to gianfar, fcoe and wireless, there's now no user of
DECLARE_MAC_BUF() left. I'm open to just killing it
right away, but that seems like a pain to coordinate
and would likely get merge conflicts, so this is much
simpler and then killing it next cycle.

 include/linux/if_ether.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- wireless-testing.orig/include/linux/if_ether.h	2009-07-15 17:13:31.000000000 +0200
+++ wireless-testing/include/linux/if_ether.h	2009-07-15 17:13:36.000000000 +0200
@@ -138,10 +138,10 @@ extern ssize_t sysfs_format_mac(char *bu
 /*
  *	Display a 6 byte device address (MAC) in a readable format.
  */
-extern char *print_mac(char *buf, const unsigned char *addr);
+extern char *print_mac(char *buf, const unsigned char *addr) __deprecated;
 #define MAC_FMT "%02x:%02x:%02x:%02x:%02x:%02x"
 #define MAC_BUF_SIZE	18
-#define DECLARE_MAC_BUF(var) char var[MAC_BUF_SIZE] __maybe_unused
+#define DECLARE_MAC_BUF(var) char var[MAC_BUF_SIZE]
 
 #endif
 


