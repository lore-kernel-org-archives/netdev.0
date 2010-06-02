From: Daniele Lacamera <root@danielinux.net>
Subject: [PATCH] TCP: tcp_hybla: Fix integer overflow in slow start increment
Date: Wed,  2 Jun 2010 14:02:04 +0200
Message-ID: <1275480124-24383-1-git-send-email-root@danielinux.net>
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, root@danielinux.net,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: root <root@kitchen.(none)>

For large values of rtt, 2^rho operation may overflow u32. Clamp down the increment to 2^16.
Signed-off-by: Daniele Lacamera <root@danielinux.net>
---
 net/ipv4/tcp_hybla.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_hybla.c b/net/ipv4/tcp_hybla.c
index c209e05..8db01d4 100644
--- a/net/ipv4/tcp_hybla.c
+++ b/net/ipv4/tcp_hybla.c
@@ -126,8 +126,8 @@ static void hybla_cong_avoid(struct sock *sk, u32 ack, u32 in_flight)
 		 * calculate 2^fract in a <<7 value.
 		 */
 		is_slowstart = 1;
-		increment = ((1 << ca->rho) * hybla_fraction(rho_fractions))
-			- 128;
+		increment = ((1 << min(ca->rho, 16U)) *
+			hybla_fraction(rho_fractions)) - 128;
 	} else {
 		/*
 		 * congestion avoidance
-- 
1.5.6.5
