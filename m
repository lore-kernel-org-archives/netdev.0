From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 1/2] [IPV4] UDP: Always checksum even if without socket filter
Date: Fri, 16 Nov 2007 10:46:26 +0800
Message-ID: <473D0482.4050705@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Wang Chen <wangchen@cn.fujitsu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:54926 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755695AbXKPCso (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 21:48:44 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave, 

The current kernel doesn't verify the udp checksum if user doesn't set a
socket filter.It's fine for LAN. But for WAN, it's not a good option.
Shall we fix it? Below is the patch to make udp checksum be always 
available.

[IPV4] UDP: Always checksum even if without socket filter
Make udp checksum be always available even if without socket filter.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 udp.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

--- linux-2.6.24-rc2.org/net/ipv4/udp.c	2007-11-09 16:37:57.000000000 +0800
+++ linux-2.6.24-rc2/net/ipv4/udp.c	2007-11-16 10:10:35.000000000 +0800
@@ -1011,10 +1011,8 @@ int udp_queue_rcv_skb(struct sock * sk, 
 		}
	}

-	if (sk->sk_filter) {
-		if (udp_lib_checksum_complete(skb))
-			goto drop;
-	}
+	if (udp_lib_checksum_complete(skb))
+		goto drop;

	if ((rc = sock_queue_rcv_skb(sk,skb)) < 0) {
		/* Note that an ENOMEM error is charged twice */

