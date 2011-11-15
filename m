From: Jesper Juhl <jj@chaosbits.net>
Subject: Re: [PATCH] net/packet: remove dead code and unneeded variable from
 prb_setup_retire_blk_timer()
Date: Tue, 15 Nov 2011 01:08:05 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1111150105500.10159@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1111150034120.9919@swampdragon.chaosbits.net> <20111114.184325.1962580278359413683.davem@davemloft.net> <alpine.LNX.2.00.1111150049500.9919@swampdragon.chaosbits.net> <20111114.184736.1515821968538974735.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: rmallon@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, eric.dumazet@gmail.com,
	xiaosuo@gmail.com, greearb@candelatech.com, loke.chetan@gmail.com,
	waltje@uWalt.NL.Mugnet.ORG, gw4pts@gw4pts.ampr.org,
	waltje@linux.com, ross.biro@gmail.com, alan@linux.intel.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111114.184736.1515821968538974735.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 14 Nov 2011, David Miller wrote:

> From: Jesper Juhl <jj@chaosbits.net>
> Date: Tue, 15 Nov 2011 00:51:57 +0100 (CET)
> 
> > On Mon, 14 Nov 2011, David Miller wrote:
> > 
> >> From: Jesper Juhl <jj@chaosbits.net>
> >> Date: Tue, 15 Nov 2011 00:37:33 +0100 (CET)
> >> 
> >> > David: You may want to pass on this one. I obviously didn't think it 
> >> > through properly - sorry :-(
> >> 
> >> It's already in my tree and pushed out to kernel.org, what in the
> >> world do you think "applied" means?
> >> 
> > I'm sorry about that. I try to be careful with my patches, but sometimes 
> > mistakes slip through - I'm only human... I do my best, but I mess up 
> > sometimes and Ryan raised a good point that I had not considered when I 
> > prepared the patch - what would you have me do except reply to his mail as 
> > I did?
> 
> Send a patch to fix things back up.

Sure, I can do that. Please see below.

I'm sorry about thiss mess and the extra work it caused you - I'll be more 
careful in the future.


From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] Revert incorrect dead-code changes to prb_setup_retire_blk_timer

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 net/packet/af_packet.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index ab10e84..82a6f34 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -516,11 +516,13 @@ static void prb_init_blk_timer(struct packet_sock *po,
 
 static void prb_setup_retire_blk_timer(struct packet_sock *po, int tx_ring)
 {
+	struct tpacket_kbdq_core *pkc;
+
 	if (tx_ring)
 		BUG();
 
-	prb_init_blk_timer(po, &po->rx_ring.prb_bdqc,
-			   prb_retire_rx_blk_timer_expired);
+	pkc = tx_ring ? &po->tx_ring.prb_bdqc : &po->rx_ring.prb_bdqc;
+	prb_init_blk_timer(po, pkc, prb_retire_rx_blk_timer_expired);
 }
 
 static int prb_calc_retire_blk_tmo(struct packet_sock *po,
-- 
1.7.7.3

-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.
