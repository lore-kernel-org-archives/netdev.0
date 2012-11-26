From: Joe Perches <joe@perches.com>
Subject: [PATCH] ip6mr: Add sizeof verification to MRT6_ASSERT and MT6_PIM
Date: Sun, 25 Nov 2012 20:26:34 -0800
Message-ID: <1353903994.2493.2.camel@joe-AO722>
References: <1353868023.6558.10.camel@joe-AO722>
	 <1353870787.30446.831.camel@edumazet-glaptop>
	 <1353872130.6558.17.camel@joe-AO722>
	 <20121125.164036.1283541826012498001.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:57426 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753911Ab2KZE0g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Nov 2012 23:26:36 -0500
In-Reply-To: <20121125.164036.1283541826012498001.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Verify the length of the user-space arguments.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/ipv6/ip6mr.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 79bb490..926ea54 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1646,6 +1646,9 @@ int ip6_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, uns
 	case MRT6_ASSERT:
 	{
 		int v;
+
+		if (optlen != sizeof(v))
+			return -EINVAL;
 		if (get_user(v, (int __user *)optval))
 			return -EFAULT;
 		mrt->mroute_do_assert = v;
@@ -1656,6 +1659,9 @@ int ip6_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, uns
 	case MRT6_PIM:
 	{
 		int v;
+
+		if (optlen != sizeof(v))
+			return -EINVAL;
 		if (get_user(v, (int __user *)optval))
 			return -EFAULT;
 		v = !!v;
