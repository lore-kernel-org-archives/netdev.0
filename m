From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH] IPv6: only modify checksum for UDP
Date: Fri, 10 Nov 2006 11:24:45 -0500
Message-ID: <4554A7CD.6040907@hp.com>
References: <20061108221332.GI29920@ftp.linux.org.uk>	<45536622.90708@hp.com> <20061109.151402.15590179.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060506020208010303020208"
Cc: viro@ftp.linux.org.uk, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:56544 "EHLO atlrel8.hp.com")
	by vger.kernel.org with ESMTP id S1946723AbWKJQYs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Nov 2006 11:24:48 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061109.151402.15590179.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060506020208010303020208
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Only change upper-layer checksum from 0 to 0xFFFF for UDP (as RFC 768 
states), not for others as RFC 4443 doesn't require it.

Signed-off-by: Brian Haley <brian.haley@hp.com>

--------------060506020208010303020208
Content-Type: text/x-patch;
 name="cksum.zero.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="cksum.zero.diff"

diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 81bd45b..dbb9b1f 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -246,8 +246,6 @@ static int icmpv6_push_pending_frames(st
 					   len, fl->proto, tmp_csum);
 		icmp6h->icmp6_cksum = tmp_csum;
 	}
-	if (icmp6h->icmp6_cksum == 0)
-		icmp6h->icmp6_cksum = -1;
 	ip6_push_pending_frames(sk);
 out:
 	return err;
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 6bc6655..baf7b82 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -536,7 +536,7 @@ static int rawv6_push_pending_frames(str
 				   &fl->fl6_dst,
 				   total_len, fl->proto, tmp_csum);
 
-	if (tmp_csum == 0)
+	if (tmp_csum == 0 && fl->proto == IPPROTO_UDP)
 		tmp_csum = -1;
 
 	csum = tmp_csum;

--------------060506020208010303020208--
