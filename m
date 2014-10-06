From: Simon Vincent <simon.vincent@xsilon.com>
Subject: [PATCH net-next] icmp6: Add new icmpv6 type for RPL control message
Date: Mon,  6 Oct 2014 11:37:06 +0100
Message-ID: <1412591826-32037-1-git-send-email-simon.vincent@xsilon.com>
Cc: Simon Vincent <simon.vincent@xsilon.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.13]:52292 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751090AbaJFKhN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 06:37:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IANA has defined a type value of 155 for RPL control messages.
We do nothing if we recieve one of these messages. This patch is to
avoid getting lots of icmpv6 unknown type messages when using RPL.

Signed-off-by: Simon Vincent <simon.vincent@xsilon.com>
---
 include/uapi/linux/icmpv6.h | 2 ++
 net/ipv6/icmp.c             | 1 +
 2 files changed, 3 insertions(+)

diff --git a/include/uapi/linux/icmpv6.h b/include/uapi/linux/icmpv6.h
index 590beda..0d493c1 100644
--- a/include/uapi/linux/icmpv6.h
+++ b/include/uapi/linux/icmpv6.h
@@ -107,6 +107,8 @@ struct icmp6hdr {
 #define ICMPV6_MOBILE_PREFIX_SOL	146
 #define ICMPV6_MOBILE_PREFIX_ADV	147
 
+#define ICMPV6_RPL_CONTROL		155
+
 /*
  *	Codes for Destination Unreachable
  */
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 141e1f3..525ad3c 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -774,6 +774,7 @@ static int icmpv6_rcv(struct sk_buff *skb)
 	case ICMPV6_DHAAD_REPLY:
 	case ICMPV6_MOBILE_PREFIX_SOL:
 	case ICMPV6_MOBILE_PREFIX_ADV:
+	case ICMPV6_RPL_CONTROL:
 		break;
 
 	default:
-- 
1.9.1
