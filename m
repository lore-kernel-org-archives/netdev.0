From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 3/3] net: Remove martian_source_keep_err goto label
Date: Mon, 28 Sep 2015 11:10:44 -0700
Message-ID: <20150928181044.20320.30541.stgit@ahduyck-vm-fedora22>
References: <20150928175512.20320.97537.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34525 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756675AbbI1SKp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 14:10:45 -0400
Received: by padhy16 with SMTP id hy16so180778401pad.1
        for <netdev@vger.kernel.org>; Mon, 28 Sep 2015 11:10:45 -0700 (PDT)
In-Reply-To: <20150928175512.20320.97537.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>

err is initialized to -EINVAL when it is declared. It is not reset until
fib_lookup which is well after the 3 users of the martian_source jump. So
resetting err to -EINVAL at martian_source label is not needed.

Removing that line obviates the need for the martian_source_keep_err label
so delete it.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 net/ipv4/route.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 43508c8d08e2..8c84a6664b30 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1759,7 +1759,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 		err = fib_validate_source(skb, saddr, daddr, tos,
 					  0, dev, in_dev, &itag);
 		if (err < 0)
-			goto martian_source_keep_err;
+			goto martian_source;
 		goto local_input;
 	}
 
@@ -1781,7 +1781,7 @@ brd_input:
 		err = fib_validate_source(skb, saddr, 0, tos, 0, dev,
 					  in_dev, &itag);
 		if (err < 0)
-			goto martian_source_keep_err;
+			goto martian_source;
 	}
 	flags |= RTCF_BROADCAST;
 	res.type = RTN_BROADCAST;
@@ -1857,8 +1857,6 @@ e_nobufs:
 	goto out;
 
 martian_source:
-	err = -EINVAL;
-martian_source_keep_err:
 	ip_handle_martian_source(dev, in_dev, skb, daddr, saddr);
 	goto out;
 }
