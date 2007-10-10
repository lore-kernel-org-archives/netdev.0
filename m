From: Brian Haley <brian.haley@hp.com>
Subject: [IPv6] Update setsockopt(IPV6_MULTICAST_IF) to support RFC 3493
Date: Wed, 10 Oct 2007 11:04:37 -0400
Message-ID: <470CEA05.8080809@hp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050505060103060407020105"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:47784 "EHLO atlrel9.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756283AbXJJPEj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2007 11:04:39 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050505060103060407020105
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

 From RFC 3493, Section 5.2:

       IPV6_MULTICAST_IF

          Set the interface to use for outgoing multicast packets.  The
          argument is the index of the interface to use.  If the
          interface index is specified as zero, the system selects the
          interface (for example, by looking up the address in a routing
          table and using the resulting interface).

This patch adds support for (index == 0) to reset the value to it's 
original state, allowing the system to choose the best interface.  IPv4 
already behaves this way.

-Brian


Signed-off-by: Brian Haley <brian.haley@hp.com>

--------------050505060103060407020105
Content-Type: text/x-patch;
 name="ipv6.multicast_if.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ipv6.multicast_if.patch"

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 532425d..309284e 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -539,6 +539,13 @@ done:
 	case IPV6_MULTICAST_IF:
 		if (sk->sk_type == SOCK_STREAM)
 			goto e_inval;
+
+		if (val == 0) {
+			np->mcast_oif = 0;
+			retv = 0;
+			break;
+		}
+
 		if (sk->sk_bound_dev_if && sk->sk_bound_dev_if != val)
 			goto e_inval;
 

--------------050505060103060407020105--
