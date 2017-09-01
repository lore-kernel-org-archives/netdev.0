From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 1/2] link_gre6: Fix for changing tclass/flowlabel
Date: Fri,  1 Sep 2017 16:08:08 +0200
Message-ID: <20170901140809.13230-2-phil@nwl.cc>
References: <20170901140809.13230-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:59753 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752031AbdIAOIe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 1 Sep 2017 10:08:34 -0400
In-Reply-To: <20170901140809.13230-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When trying to change tclass or flowlabel of a GREv6 tunnel which has
the respective value set already, the code accidentally bitwise OR'ed
the old and the new value, leading to unexpected results. Fix this by
clearing the relevant bits of flowinfo variable prior to assigning the
new value.

Fixes: af89576d7a8c4 ("iproute2: GRE over IPv6 tunnel support.")
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/link_gre6.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/ip/link_gre6.c b/ip/link_gre6.c
index 4d3d4b54210b9..447ac5d78ab7b 100644
--- a/ip/link_gre6.c
+++ b/ip/link_gre6.c
@@ -288,6 +288,7 @@ get_failed:
 			else {
 				if (get_u8(&uval, *argv, 16))
 					invarg("invalid TClass", *argv);
+				flowinfo &= ~IP6_FLOWINFO_TCLASS;
 				flowinfo |= htonl((__u32)uval << 20) & IP6_FLOWINFO_TCLASS;
 				flags &= ~IP6_TNL_F_USE_ORIG_TCLASS;
 			}
@@ -303,6 +304,7 @@ get_failed:
 					invarg("invalid Flowlabel", *argv);
 				if (uval > 0xFFFFF)
 					invarg("invalid Flowlabel", *argv);
+				flowinfo &= ~IP6_FLOWINFO_FLOWLABEL;
 				flowinfo |= htonl(uval) & IP6_FLOWINFO_FLOWLABEL;
 				flags &= ~IP6_TNL_F_USE_ORIG_FLOWLABEL;
 			}
-- 
2.13.1
