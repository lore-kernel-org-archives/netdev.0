From: Akinobu Mita <akinobu.mita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 28/29] net/: rename net_random() to prandom_u32()
Date: Mon, 24 Dec 2012 11:14:15 +0900
Message-ID: <1356315256-6572-29-git-send-email-akinobu.mita@gmail.com>
References: <1356315256-6572-1-git-send-email-akinobu.mita@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Steffen Klassert <steffen.klassert-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org>, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Vlad Yasevich <vyasevich-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Akinobu Mita <akinobu.mita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Venkat Venkatsubra <venkat.x.venkatsubra-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Sridhar Samudrala <sri-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1356315256-6572-1-git-send-email-akinobu.mita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

Use more preferable function name which implies using a pseudo-random
number generator.

Signed-off-by: Akinobu Mita <akinobu.mita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Cc: Venkat Venkatsubra <venkat.x.venkatsubra-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Cc: Vlad Yasevich <vyasevich-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Sridhar Samudrala <sri-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Cc: Steffen Klassert <steffen.klassert-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org>
Cc: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 include/net/red.h         | 2 +-
 net/802/garp.c            | 2 +-
 net/openvswitch/actions.c | 2 +-
 net/rds/bind.c            | 2 +-
 net/sctp/socket.c         | 2 +-
 net/xfrm/xfrm_state.c     | 2 +-
 6 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/net/red.h b/include/net/red.h
index ef46058..168bb2f 100644
--- a/include/net/red.h
+++ b/include/net/red.h
@@ -303,7 +303,7 @@ static inline unsigned long red_calc_qavg(const struct red_parms *p,
 
 static inline u32 red_random(const struct red_parms *p)
 {
-	return reciprocal_divide(net_random(), p->max_P_reciprocal);
+	return reciprocal_divide(prandom_u32(), p->max_P_reciprocal);
 }
 
 static inline int red_mark_probability(const struct red_parms *p,
diff --git a/net/802/garp.c b/net/802/garp.c
index 8456f5d..cf7410d 100644
--- a/net/802/garp.c
+++ b/net/802/garp.c
@@ -397,7 +397,7 @@ static void garp_join_timer_arm(struct garp_applicant *app)
 {
 	unsigned long delay;
 
-	delay = (u64)msecs_to_jiffies(garp_join_time) * net_random() >> 32;
+	delay = (u64)msecs_to_jiffies(garp_join_time) * prandom_u32() >> 32;
 	mod_timer(&app->join_timer, jiffies + delay);
 }
 
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index ac2defe..257bc36 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -404,7 +404,7 @@ static int sample(struct datapath *dp, struct sk_buff *skb,
 		 a = nla_next(a, &rem)) {
 		switch (nla_type(a)) {
 		case OVS_SAMPLE_ATTR_PROBABILITY:
-			if (net_random() >= nla_get_u32(a))
+			if (prandom_u32() >= nla_get_u32(a))
 				return 0;
 			break;
 
diff --git a/net/rds/bind.c b/net/rds/bind.c
index 637bde5..7f95f4b 100644
--- a/net/rds/bind.c
+++ b/net/rds/bind.c
@@ -118,7 +118,7 @@ static int rds_add_bound(struct rds_sock *rs, __be32 addr, __be16 *port)
 		rover = be16_to_cpu(*port);
 		last = rover;
 	} else {
-		rover = max_t(u16, net_random(), 2);
+		rover = max_t(u16, prandom_u32(), 2);
 		last = rover - 1;
 	}
 
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 9e65758..95860aa 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -5899,7 +5899,7 @@ static long sctp_get_port_local(struct sock *sk, union sctp_addr *addr)
 
 		inet_get_local_port_range(&low, &high);
 		remaining = (high - low) + 1;
-		rover = net_random() % remaining + low;
+		rover = prandom_u32() % remaining + low;
 
 		do {
 			rover++;
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 3459692..35ddaab 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1546,7 +1546,7 @@ int xfrm_alloc_spi(struct xfrm_state *x, u32 low, u32 high)
 	} else {
 		u32 spi = 0;
 		for (h=0; h<high-low+1; h++) {
-			spi = low + net_random()%(high-low+1);
+			spi = low + prandom_u32() % (high - low + 1);
 			x0 = xfrm_state_lookup(net, mark, &x->id.daddr, htonl(spi), x->id.proto, x->props.family);
 			if (x0 == NULL) {
 				x->id.spi = htonl(spi);
-- 
1.7.11.7
