From: Jan Moskyto Matejka <mq@suse.cz>
Subject: [PATCH] inet: defines IPPROTO_* needed for module alias generation
Date: Thu,  6 Feb 2014 12:10:00 +0100
Message-ID: <1391685000-7346-1-git-send-email-mq@suse.cz>
Cc: Jan Moskyto Matejka <mq@suse.cz>,
	"Carlos O'Donell" <carlos@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:38621 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755875AbaBFLN3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Feb 2014 06:13:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit cfd280c91253 ("net: sync some IP headers with glibc") changed a set of
define's to an enum (with no explanation why) which introduced a bug
in module mip6 where aliases are generated using the IPPROTO_* defines;
mip6 doesn't load if require_module called with the aliases from
xfrm_get_type().

Reverting this change back to define's to fix the aliases.

modinfo mip6 (before this change)
alias:          xfrm-type-10-IPPROTO_DSTOPTS
alias:          xfrm-type-10-IPPROTO_ROUTING

modinfo mip6 (after this change)
alias:          xfrm-type-10-43
alias:          xfrm-type-10-60

Signed-off-by: Jan Moskyto Matejka <mq@suse.cz>
---
 include/uapi/linux/in6.h | 23 +++++++----------------
 1 file changed, 7 insertions(+), 16 deletions(-)

diff --git a/include/uapi/linux/in6.h b/include/uapi/linux/in6.h
index 633b93c..e9a1d2d97 100644
--- a/include/uapi/linux/in6.h
+++ b/include/uapi/linux/in6.h
@@ -128,22 +128,13 @@ struct in6_flowlabel_req {
  *	IPV6 extension headers
  */
 #if __UAPI_DEF_IPPROTO_V6
-enum {
-  IPPROTO_HOPOPTS = 0,		/* IPv6 hop-by-hop options      */
-#define IPPROTO_HOPOPTS		IPPROTO_HOPOPTS
-  IPPROTO_ROUTING = 43,		/* IPv6 routing header          */
-#define IPPROTO_ROUTING		IPPROTO_ROUTING
-  IPPROTO_FRAGMENT = 44,	/* IPv6 fragmentation header    */
-#define IPPROTO_FRAGMENT	IPPROTO_FRAGMENT
-  IPPROTO_ICMPV6 = 58,		/* ICMPv6                       */
-#define IPPROTO_ICMPV6		IPPROTO_ICMPV6
-  IPPROTO_NONE = 59,		/* IPv6 no next header          */
-#define IPPROTO_NONE		IPPROTO_NONE
-  IPPROTO_DSTOPTS = 60,		/* IPv6 destination options     */
-#define IPPROTO_DSTOPTS		IPPROTO_DSTOPTS
-  IPPROTO_MH = 135,		/* IPv6 mobility header         */
-#define IPPROTO_MH		IPPROTO_MH
-};
+#define IPPROTO_HOPOPTS		0	/* IPv6 hop-by-hop options	*/
+#define IPPROTO_ROUTING		43	/* IPv6 routing header		*/
+#define IPPROTO_FRAGMENT	44	/* IPv6 fragmentation header	*/
+#define IPPROTO_ICMPV6		58	/* ICMPv6			*/
+#define IPPROTO_NONE		59	/* IPv6 no next header		*/
+#define IPPROTO_DSTOPTS		60	/* IPv6 destination options	*/
+#define IPPROTO_MH		135	/* IPv6 mobility header		*/
 #endif /* __UAPI_DEF_IPPROTO_V6 */
 
 /*
-- 
1.8.4.5
