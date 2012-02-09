From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH 1/2 net-next] ipv6: helper function to get tclass
Date: Thu, 9 Feb 2012 20:34:41 +0100
Message-ID: <20120209203441.24c97aa3@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27847 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757904Ab2BITep (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Feb 2012 14:34:45 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q19JYiWn009108
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 9 Feb 2012 14:34:44 -0500
Received: from griffin (ovpn-116-57.ams2.redhat.com [10.36.116.57])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id q19JYgw9017779
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES128-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 9 Feb 2012 14:34:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement helper inline function to get traffic class from IPv6 header.

Signed-off-by: Jiri Benc <jbenc@redhat.com>

---
 include/linux/ipv6.h |    5 +++++
 net/ipv6/datagram.c  |    2 +-
 2 files changed, 6 insertions(+), 1 deletion(-)

--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -233,6 +233,11 @@ static inline struct ipv6hdr *ipipv6_hdr
 	return (struct ipv6hdr *)skb_transport_header(skb);
 }
 
+static inline __u8 ipv6_tclass(const struct ipv6hdr *iph)
+{
+	return (ntohl(*(__be32 *)iph) >> 20) & 0xff;
+}
+
 /* 
    This structure contains results of exthdrs parsing
    as offsets from skb->nh.
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -485,7 +485,7 @@ int datagram_recv_ctl(struct sock *sk, s
 	}
 
 	if (np->rxopt.bits.rxtclass) {
-		int tclass = (ntohl(*(__be32 *)ipv6_hdr(skb)) >> 20) & 0xff;
+		int tclass = ipv6_tclass(ipv6_hdr(skb));
 		put_cmsg(msg, SOL_IPV6, IPV6_TCLASS, sizeof(tclass), &tclass);
 	}
 
