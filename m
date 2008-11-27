From: Patrick McHardy <kaber@trash.net>
Subject: netlink: allow empty nested attributes
Date: Thu, 27 Nov 2008 13:57:19 +0100
Message-ID: <492E992F.7040703@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070709040006030001010602"
Cc: Thomas Graf <tgraf@suug.ch>,
	Johannes Berg <johannes@sipsolutions.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49456 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751125AbYK0M5W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 07:57:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070709040006030001010602
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------070709040006030001010602
Content-Type: text/x-patch;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

commit 57b0afc97f8249f0b4f665aa285ed89a9178ba42
Author: Patrick McHardy <kaber@trash.net>
Date:   Thu Nov 27 13:40:31 2008 +0100

    netlink: allow empty nested attributes
    
    validate_nla() currently doesn't allow empty nested attributes. This
    makes userspace code unnecessarily complicated when starting and ending
    the nested attribute is done by generic upper level code and the inner
    attributes are dumped by a module.
    
    Add a special case to accept empty nested attributes. When the nested
    attribute is non empty, the same checks as before are performed.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netlink/attr.c b/net/netlink/attr.c
index c83fea7..56c3ce7 100644
--- a/net/netlink/attr.c
+++ b/net/netlink/attr.c
@@ -83,6 +83,12 @@ static int validate_nla(struct nlattr *nla, int maxtype,
 		if (attrlen < NLA_ALIGN(pt->len) + NLA_HDRLEN + nla_len(nla))
 			return -ERANGE;
 		break;
+	case NLA_NESTED:
+		/* a nested attributes is allowed to be empty; if its not,
+		 * it must have a size of at least NLA_HDRLEN.
+		 */
+		if (attrlen == 0)
+			break;
 	default:
 		if (pt->len)
 			minlen = pt->len;

--------------070709040006030001010602--
