From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH]: Fix memory leak in ah6.c
Date: Fri, 28 May 2004 12:50:29 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40B71975.1080909@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050200030200070506070809"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050200030200070506070809
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi Dave,

this patch fixes a memory leak in ah6.c. iph is not freed when
ipv6_clear_mutable_options fails.

Regards
Patrick

--------------050200030200070506070809
Content-Type: text/x-patch;
 name="ah6-memleak.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ah6-memleak.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/05/28 12:21:37+02:00 kaber@trash.net 
#   [IPSEC]: Fix memory leak in ah6.c
# 
# net/ipv6/ah6.c
#   2004/05/28 12:21:29+02:00 kaber@trash.net +3 -1
#   [IPSEC]: Fix memory leak in ah6.c
# 
diff -Nru a/net/ipv6/ah6.c b/net/ipv6/ah6.c
--- a/net/ipv6/ah6.c	2004-05-28 12:34:25 +02:00
+++ b/net/ipv6/ah6.c	2004-05-28 12:34:25 +02:00
@@ -190,7 +190,7 @@
 		memcpy(skb->nh.ipv6h, iph, hdr_len);
 		nexthdr = ipv6_clear_mutable_options(skb, &nh_offset, XFRM_POLICY_OUT);
 		if (nexthdr == 0)
-			goto error;
+			goto error_free_iph;
 
 		skb->nh.raw[nh_offset] = IPPROTO_AH;
 		skb->nh.ipv6h->payload_len = htons(skb->len - sizeof(struct ipv6hdr));
@@ -239,6 +239,8 @@
 		goto error_nolock;
 	}
 	return NET_XMIT_BYPASS;
+error_free_iph:
+	kfree(iph);
 error:
 	spin_unlock_bh(&x->lock);
 error_nolock:

--------------050200030200070506070809--
