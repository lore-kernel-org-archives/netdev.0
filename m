From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH] net: Move destructor from neigh->ops
	to neigh_params
Date: Mon, 06 Mar 2006 21:44:50 -0800
Message-ID: <ada7j7624h9.fsf@cisco.com>
References: <adazmlmmy7v.fsf@cisco.com> <20060306211630.0df79464.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060306211630.0df79464.akpm@osdl.org> (Andrew Morton's message
	of "Mon, 6 Mar 2006 21:16:30 -0800")
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

    Roland> struct neigh_ops currently has a destructor field, which
    Roland> no in-kernel drivers outside of infiniband use.

    Andrew> net/atm/clip.c begs to disagree.

err... my fault for trusting the patch changelog and not
double-checking.  I think the fix is as simple as, although, given my
lack of ATM gear, this is untested:

diff --git a/net/atm/clip.c b/net/atm/clip.c
index 73370de..9d72817 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -289,7 +289,6 @@ static void clip_neigh_error(struct neig
 
 static struct neigh_ops clip_neigh_ops = {
 	.family =		AF_INET,
-	.destructor =		clip_neigh_destroy,
 	.solicit =		clip_neigh_solicit,
 	.error_report =		clip_neigh_error,
 	.output =		dev_queue_xmit,
@@ -346,6 +345,7 @@ static struct neigh_table clip_tbl = {
 
 	/* parameters are copied from ARP ... */
 	.parms = {
+		.destructor		= clip_neigh_destroy,
 		.tbl 			= &clip_tbl,
 		.base_reachable_time 	= 30 * HZ,
 		.retrans_time 		= 1 * HZ,
