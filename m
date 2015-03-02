From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 08/15] arp: Remove special case to give AX25 it's open arp operations.
Date: Mon, 02 Mar 2015 00:06:31 -0600
Message-ID: <87385o7x20.fsf_-_@x220.int.ebiederm.org>
References: <87pp8xx6ik.fsf@x220.int.ebiederm.org>
	<20150227.162131.431559184124647735.davem@davemloft.net>
	<87mw3yg8da.fsf@x220.int.ebiederm.org>
	<20150301.230306.2023670900391030920.davem@davemloft.net>
	<871tl8dlxn.fsf@x220.int.ebiederm.org>
	<87lhjg9byo.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>,
	linux-hams@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <87lhjg9byo.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Sun, 01 Mar 2015 23:59:11 -0600")
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The special case has been pushed out into ax25_neigh_construct so there
is no need to keep this code in arp.c

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/ipv4/arp.c | 37 -------------------------------------
 1 file changed, 37 deletions(-)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 205e1472aa78..2557cf9a4648 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -149,14 +149,6 @@ static const struct neigh_ops arp_direct_ops = {
 	.connected_output =	neigh_direct_output,
 };
 
-static const struct neigh_ops arp_broken_ops = {
-	.family =		AF_INET,
-	.solicit =		arp_solicit,
-	.error_report =		arp_error_report,
-	.output =		neigh_compat_output,
-	.connected_output =	neigh_compat_output,
-};
-
 struct neigh_table arp_tbl = {
 	.family		= AF_INET,
 	.key_len	= 4,
@@ -260,35 +252,6 @@ static int arp_constructor(struct neighbour *neigh)
 		   in old paradigm.
 		 */
 
-#if 1
-		/* So... these "amateur" devices are hopeless.
-		   The only thing, that I can say now:
-		   It is very sad that we need to keep ugly obsolete
-		   code to make them happy.
-
-		   They should be moved to more reasonable state, now
-		   they use rebuild_header INSTEAD OF hard_start_xmit!!!
-		   Besides that, they are sort of out of date
-		   (a lot of redundant clones/copies, useless in 2.1),
-		   I wonder why people believe that they work.
-		 */
-		switch (dev->type) {
-		default:
-			break;
-		case ARPHRD_ROSE:
-#if IS_ENABLED(CONFIG_AX25)
-		case ARPHRD_AX25:
-#if IS_ENABLED(CONFIG_NETROM)
-		case ARPHRD_NETROM:
-#endif
-			neigh->ops = &arp_broken_ops;
-			neigh->output = neigh->ops->output;
-			return 0;
-#else
-			break;
-#endif
-		}
-#endif
 		if (neigh->type == RTN_MULTICAST) {
 			neigh->nud_state = NUD_NOARP;
 			arp_mc_map(addr, neigh->ha, dev, 1);
-- 
2.2.1

