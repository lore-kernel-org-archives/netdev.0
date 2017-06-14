From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2] link_gre6: really support encaplimit option
Date: Wed, 14 Jun 2017 18:45:42 +0200
Message-ID: <1497458742-6068-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:53807 "EHLO
        proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752228AbdFNQp5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 12:45:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This option is documented in gre6 help, but was not supported.

Fixes: af89576d7a8c ("iproute2: GRE over IPv6 tunnel support.")
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 ip/link_gre6.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/ip/link_gre6.c b/ip/link_gre6.c
index 205bada78054..4d3d4b54210b 100644
--- a/ip/link_gre6.c
+++ b/ip/link_gre6.c
@@ -355,6 +355,18 @@ get_failed:
 					invarg("invalid fwmark\n", *argv);
 				flags &= ~IP6_TNL_F_USE_ORIG_FWMARK;
 			}
+		} else if (strcmp(*argv, "encaplimit") == 0) {
+			NEXT_ARG();
+			if (strcmp(*argv, "none") == 0) {
+				flags |= IP6_TNL_F_IGN_ENCAP_LIMIT;
+			} else {
+				__u8 uval;
+
+				if (get_u8(&uval, *argv, 0) < -1)
+					invarg("invalid ELIM", *argv);
+				encap_limit = uval;
+				flags &= ~IP6_TNL_F_IGN_ENCAP_LIMIT;
+			}
 		} else
 			usage();
 		argc--; argv++;
-- 
2.8.1
