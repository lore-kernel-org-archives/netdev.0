From: Paul Bolle <pebolle@tiscali.nl>
Subject: [PATCH] gigaset: silence GCC warning for unused 'format_ie'
Date: Sun, 15 Jul 2012 11:11:55 +0200
Message-ID: <1342343515.1780.2.camel@x61.thuisdomein>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Tilman Schmidt <tilman@imap.cc>, Hansjoerg Lipp <hjlipp@web.de>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cpsmtpb-ews07.kpnxchange.com ([213.75.39.10]:1397 "EHLO
	cpsmtpb-ews07.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751060Ab2GOJMC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jul 2012 05:12:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Building Gigaset's CAPI support without Gigaset's debugging enabled
triggers this GCC warning:
    'format_ie' defined but not used [-Wunused-function]

Silence this warning by wrapping format_ie() in an "#ifdef
CONFIG_GIGASET_DEBUG" and "#endif" pair.

Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
---
 drivers/isdn/gigaset/capi.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/isdn/gigaset/capi.c b/drivers/isdn/gigaset/capi.c
index 27e4a3e..68452b7 100644
--- a/drivers/isdn/gigaset/capi.c
+++ b/drivers/isdn/gigaset/capi.c
@@ -288,6 +288,7 @@ static inline void dump_rawmsg(enum debuglevel level, const char *tag,
  * format CAPI IE as string
  */
 
+#ifdef CONFIG_GIGASET_DEBUG
 static const char *format_ie(const char *ie)
 {
 	static char result[3 * MAX_FMT_IE_LEN];
@@ -313,6 +314,7 @@ static const char *format_ie(const char *ie)
 	*--pout = 0;
 	return result;
 }
+#endif
 
 /*
  * emit DATA_B3_CONF message
-- 
1.7.7.6
