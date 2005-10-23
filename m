From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [1/3] [NEIGH] Print stack trace in neigh_add_timer
Date: Sun, 23 Oct 2005 17:31:12 +1000
Message-ID: <20051023073112.GA17626@gondor.apana.org.au>
References: <43534273.2050106@reub.net> <E1ETaJB-0004a0-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="pf9I7BMVVzbSWLtt"
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, acme@conectiva.com.br, davem@davemloft.net,
	greearb@candelatech.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751429AbVJWHbW@vger.kernel.org>
To: Reuben Farrelly <reuben-lkml@reub.net>
Content-Disposition: inline
In-Reply-To: <E1ETaJB-0004a0-00@gondolin.me.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--pf9I7BMVVzbSWLtt
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

[NEIGH] Print stack trace in neigh_add_timer

Stack traces are very helpful in determining the exact nature of a bug.
So let's print a stack trace when the timer is added twice.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--pf9I7BMVVzbSWLtt
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="p1.patch"

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -732,6 +732,7 @@ static inline void neigh_add_timer(struc
 	if (unlikely(mod_timer(&n->timer, when))) {
 		printk("NEIGH: BUG, double timer add, state is %x\n",
 		       n->nud_state);
+		dump_stack();
 	}
 }
 

--pf9I7BMVVzbSWLtt--
