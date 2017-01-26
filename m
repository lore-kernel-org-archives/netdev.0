From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 4/5] gtp: Rename jump labels in gtp_encap_enable()
Date: Thu, 26 Jan 2017 11:20:28 +0100
Message-ID: <78c09980-bc36-f474-8a26-541f90ca55c4@users.sourceforge.net>
References: <698070a4-e08e-78e5-0214-df69783cce22@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Harald Welte <laforge@gnumonks.org>,
        Johannes Berg <johannes.berg@intel.com>,
        Pablo Neira <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <698070a4-e08e-78e5-0214-df69783cce22@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Thu, 26 Jan 2017 10:48:40 +0100

Adjust jump labels according to the Linux coding style convention.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/gtp.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 7e38786361d8..2d4ddc000919 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -840,20 +840,20 @@ static int gtp_encap_enable(struct net_device *dev, struct gtp_dev *gtp,
 	if (sock0->sk->sk_protocol != IPPROTO_UDP) {
 		netdev_dbg(dev, "socket fd=%d not UDP\n", fd_gtp0);
 		err = -EINVAL;
-		goto err1;
+		goto put_socket;
 	}
 
 	sock1u = sockfd_lookup(fd_gtp1, &err);
 	if (!sock1u) {
 		netdev_dbg(dev, "socket fd=%d not found (gtp1u)\n", fd_gtp1);
 		err = -ENOENT;
-		goto err1;
+		goto put_socket;
 	}
 
 	if (sock1u->sk->sk_protocol != IPPROTO_UDP) {
 		netdev_dbg(dev, "socket fd=%d not UDP\n", fd_gtp1);
 		err = -EINVAL;
-		goto err2;
+		goto put_socket_u;
 	}
 
 	netdev_dbg(dev, "enable gtp on %p, %p\n", sock0, sock1u);
@@ -873,9 +873,9 @@ static int gtp_encap_enable(struct net_device *dev, struct gtp_dev *gtp,
 	setup_udp_tunnel_sock(sock_net(gtp->sock1u->sk), gtp->sock1u, &tuncfg);
 
 	err = 0;
-err2:
+put_socket_u:
 	sockfd_put(sock1u);
-err1:
+put_socket:
 	sockfd_put(sock0);
 	return err;
 }
-- 
2.11.0
