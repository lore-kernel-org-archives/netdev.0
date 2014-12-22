From: Heiner Kallweit <hkallweit1@gmail.com>
Subject: [PATCH iproute2] ip: allow ip address show to list addresses with
 certain flags not being set
Date: Mon, 22 Dec 2014 20:18:43 +0100
Message-ID: <54986E93.4030108@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:54437 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932111AbaLVTTX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2014 14:19:23 -0500
Received: by mail-wi0-f179.google.com with SMTP id ex7so8894734wid.12
        for <netdev@vger.kernel.org>; Mon, 22 Dec 2014 11:19:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sometimes it's needed to have "ip address show" list only addresses
with certain flags not being set, e.g. in network scripts.
As an example one might want to exclude addresses in "tentative"
or "deprecated" state.

Support listing addresses with flags tentative, deprecated, dadfailed
not being set by prefixing the respective flag with a minus.

Signed-off-by: Heiner Kallweit <hkallweit1@gmail.com>
---
 ip/ipaddress.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 221ae1f..a071572 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -80,7 +80,7 @@ static void usage(void)
 	fprintf(stderr, "SCOPE-ID := [ host | link | global | NUMBER ]\n");
 	fprintf(stderr, "FLAG-LIST := [ FLAG-LIST ] FLAG\n");
 	fprintf(stderr, "FLAG  := [ permanent | dynamic | secondary | primary |\n");
-	fprintf(stderr, "           tentative | deprecated | dadfailed | temporary |\n");
+	fprintf(stderr, "           [-]tentative | [-]deprecated | [-]dadfailed | temporary |\n");
 	fprintf(stderr, "           CONFFLAG-LIST ]\n");
 	fprintf(stderr, "CONFFLAG-LIST := [ CONFFLAG-LIST ] CONFFLAG\n");
 	fprintf(stderr, "CONFFLAG  := [ home | nodad | mngtmpaddr | noprefixroute ]\n");
@@ -1261,9 +1261,15 @@ static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
 		} else if (strcmp(*argv, "tentative") == 0) {
 			filter.flags |= IFA_F_TENTATIVE;
 			filter.flagmask |= IFA_F_TENTATIVE;
+		} else if (strcmp(*argv, "-tentative") == 0) {
+			filter.flags &= ~IFA_F_TENTATIVE;
+			filter.flagmask |= IFA_F_TENTATIVE;
 		} else if (strcmp(*argv, "deprecated") == 0) {
 			filter.flags |= IFA_F_DEPRECATED;
 			filter.flagmask |= IFA_F_DEPRECATED;
+		} else if (strcmp(*argv, "-deprecated") == 0) {
+			filter.flags &= ~IFA_F_DEPRECATED;
+			filter.flagmask |= IFA_F_DEPRECATED;
 		} else if (strcmp(*argv, "home") == 0) {
 			filter.flags |= IFA_F_HOMEADDRESS;
 			filter.flagmask |= IFA_F_HOMEADDRESS;
@@ -1279,6 +1285,9 @@ static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
 		} else if (strcmp(*argv, "dadfailed") == 0) {
 			filter.flags |= IFA_F_DADFAILED;
 			filter.flagmask |= IFA_F_DADFAILED;
+		} else if (strcmp(*argv, "-dadfailed") == 0) {
+			filter.flags &= ~IFA_F_DADFAILED;
+			filter.flagmask |= IFA_F_DADFAILED;
 		} else if (strcmp(*argv, "label") == 0) {
 			NEXT_ARG();
 			filter.label = *argv;
-- 
2.2.1
