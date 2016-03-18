From: David Decotigny <ddecotig@gmail.com>
Subject: [PATCH v1 2/2] netlink: add support for NIC driver ioctls
Date: Thu, 17 Mar 2016 17:03:56 -0700
Message-ID: <1458259436-85275-3-git-send-email-ddecotig@gmail.com>
References: <1458259436-85275-1-git-send-email-ddecotig@gmail.com>
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	David Decotigny <decot@googlers.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	Edward Cree <ecree@solarflare.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Thomas Graf <tgraf@suug.ch>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Ken-ichirou MATSUZAWA <chamaken@gmail.com>,
	Florian Westphal <fw@strlen.de>,
	David Herrmann <dh.herrmann@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33560 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966844AbcCRAEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2016 20:04:10 -0400
In-Reply-To: <1458259436-85275-1-git-send-email-ddecotig@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Decotigny <decot@googlers.com>

This patch removes the requirement that ethtool be tied to the support
of a specific L3 protocol (ethtool uses an AF_INET socket today).

Signed-off-by: David Decotigny <decot@googlers.com>
---
 net/netlink/af_netlink.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index c841679..215fc08 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1033,6 +1033,14 @@ static int netlink_getname(struct socket *sock, struct sockaddr *addr,
 	return 0;
 }
 
+static int netlink_ioctl(struct socket *sock, unsigned int cmd,
+			 unsigned long arg)
+{
+	/* try to hand this ioctl down to the NIC drivers.
+	 */
+	return -ENOIOCTLCMD;
+}
+
 static struct sock *netlink_getsockbyportid(struct sock *ssk, u32 portid)
 {
 	struct sock *sock;
@@ -2494,7 +2502,7 @@ static const struct proto_ops netlink_ops = {
 	.accept =	sock_no_accept,
 	.getname =	netlink_getname,
 	.poll =		datagram_poll,
-	.ioctl =	sock_no_ioctl,
+	.ioctl =	netlink_ioctl,
 	.listen =	sock_no_listen,
 	.shutdown =	sock_no_shutdown,
 	.setsockopt =	netlink_setsockopt,
-- 
2.8.0.rc3.226.g39d4020
