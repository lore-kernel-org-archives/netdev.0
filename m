From: alexander.duyck@gmail.com
Subject: [net PATCH 2/2] vxlan: Fix boolean flip in
 VXLAN_F_UDP_ZERO_CSUM6_[TX|RX]
Date: Mon, 24 Nov 2014 20:08:38 -0800
Message-ID: <20141125040838.13612.54674.stgit@ahduyck-workstation.home>
References: <20141125035808.13612.52556.stgit@ahduyck-workstation.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>,
	davem@davemloft.net, Tom Herbert <therbert@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:45508 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751290AbaKYEIk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 23:08:40 -0500
Received: by mail-pd0-f174.google.com with SMTP id w10so11142254pde.33
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2014 20:08:40 -0800 (PST)
In-Reply-To: <20141125035808.13612.52556.stgit@ahduyck-workstation.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>

In "vxlan: Call udp_sock_create" there was a logic error that resulted in
the default for IPv6 VXLAN tunnels going from using checksums to not using
checksums.  Since there is currently no support in iproute2 for setting
these values it means that a kernel after the change cannot talk over a IPv6
VXLAN tunnel to a kernel prior the change.

Fixes: 3ee64f3 ("vxlan: Call udp_sock_create")

Cc: Tom Herbert <therbert@google.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/vxlan.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index e1e335c..be4649a 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2306,9 +2306,9 @@ static struct socket *vxlan_create_sock(struct net *net, bool ipv6,
 	if (ipv6) {
 		udp_conf.family = AF_INET6;
 		udp_conf.use_udp6_tx_checksums =
-		    !!(flags & VXLAN_F_UDP_ZERO_CSUM6_TX);
+		    !(flags & VXLAN_F_UDP_ZERO_CSUM6_TX);
 		udp_conf.use_udp6_rx_checksums =
-		    !!(flags & VXLAN_F_UDP_ZERO_CSUM6_RX);
+		    !(flags & VXLAN_F_UDP_ZERO_CSUM6_RX);
 	} else {
 		udp_conf.family = AF_INET;
 		udp_conf.local_ip.s_addr = INADDR_ANY;
