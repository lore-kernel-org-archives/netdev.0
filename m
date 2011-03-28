From: David Miller <davem@davemloft.net>
Subject: Re: BUG: ping without route segfaults in dst_release
Date: Mon, 28 Mar 2011 16:51:49 -0700 (PDT)
Message-ID: <20110328.165149.193711805.davem@davemloft.net>
References: <4D911758.3010608@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev@vger.kernel.org, kernel@pengutronix.de
To: mkl@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <4D911758.3010608@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Tue, 29 Mar 2011 01:18:48 +0200

> root@ptx:~ ping 130.75.1.32
> PING 130.75.1.32 (130.75[   10.160000] Unable to handle kernel paging request at virtual address ffffffdb

Well, that was easy enough :-)

--------------------
ipv4: Don't ip_rt_put() an error pointer in RAW sockets.

Reported-by: Marc Kleine-Budde <mkl@pengutronix.de>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/raw.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index e837ffd..2d3c72e 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -569,6 +569,7 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		rt = ip_route_output_flow(sock_net(sk), &fl4, sk);
 		if (IS_ERR(rt)) {
 			err = PTR_ERR(rt);
+			rt = NULL;
 			goto done;
 		}
 	}
-- 
1.7.4.1

