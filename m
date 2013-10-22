From: Dave Taht <dave.taht@bufferbloat.net>
Subject: [PATCH 2/2] codel: eliminate maxpacket as an inner bound
Date: Mon, 21 Oct 2013 18:19:57 -0700
Message-ID: <1382404797-17239-3-git-send-email-dave.taht@bufferbloat.net>
References: <1382404797-17239-1-git-send-email-dave.taht@bufferbloat.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Dave Taht <dave.taht@bufferbloat.net>
To: netdev@vger.kernel.org,
	codel@lists.bufferbloat.net
Return-path: <codel-bounces@lists.bufferbloat.net>
In-Reply-To: <1382404797-17239-1-git-send-email-dave.taht@bufferbloat.net>
List-Unsubscribe: <https://lists.bufferbloat.net/options/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=unsubscribe>
List-Archive: <https://lists.bufferbloat.net/pipermail/codel>
List-Post: <mailto:codel@lists.bufferbloat.net>
List-Help: <mailto:codel-request@lists.bufferbloat.net?subject=help>
List-Subscribe: <https://lists.bufferbloat.net/listinfo/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=subscribe>
Sender: codel-bounces@lists.bufferbloat.net
Errors-To: codel-bounces@lists.bufferbloat.net
List-Id: netdev.vger.kernel.org

As there is always at least one packet in the device driver or
rate limiter, the maxpacket bound (an artifact of the ns2 code)
is unneeded.

Also: in the case of TSO/GSO/GRO, it can scale well above
(to 64k) what codel's designers intended.

Someday the maxpacket variable could be eliminated entirely,
but for now it is a useful indicator of "oops, I didn't turn
off tso/gso/gro somewhere".

Signed-off-by: Dave Taht <dave.taht@bufferbloat.net>
---
 include/net/codel.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/codel.h b/include/net/codel.h
index 389cf62..319a296 100644
--- a/include/net/codel.h
+++ b/include/net/codel.h
@@ -225,7 +225,7 @@ static bool codel_should_drop(const struct sk_buff *skb,
 		stats->maxpacket = qdisc_pkt_len(skb);
 
 	if (codel_time_before(vars->ldelay, params->target) ||
-	    sch->qstats.backlog <= stats->maxpacket) {
+	    sch->qstats.backlog <= 0) {
 		/* went below - stay below for at least interval */
 		vars->first_above_time = 0;
 		return false;
-- 
1.7.9.5
