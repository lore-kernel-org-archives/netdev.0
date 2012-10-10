From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next? V2] pktgen: Use simpler test for non-zero ipv6
 address
Date: Wed, 10 Oct 2012 12:23:25 -0700
Message-ID: <1349897005.2035.24.camel@joe-AO722>
References: <1349894559.2035.12.camel@joe-AO722>
	 <1349895710.21172.7235.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Brian Haley <brian.haley@hp.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1349895710.21172.7235.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reduces object size and should be slightly faster.

allyesconfig: 
$ size net/core/pktgen.o*
   text	   data	    bss	    dec	    hex	filename
  52284	   4321	  11840	  68445	  10b5d	net/core/pktgen.o.new
  52310	   4293	  11848	  68451	  10b63	net/core/pktgen.o.old
 
Signed-off-by: Joe Perches <joe@perches.com>
---
> What about ipv6_addr_any() ?

That's better I guess.
I forgot about it and didn't see it.
I saw the IPV6_ADDR_ANY type tests and
didn't look further.

Anyway, it's odd that it generates slightly larger code
than the original patch's direct tests in 32bit with
gcc 4.7.2.  Perhaps an interesting lack of optimization?

cheers, Joe

 net/core/pktgen.c |    6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 148e73d..a811a7d 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2422,11 +2422,7 @@ static void mod_cur_headers(struct pktgen_dev *pkt_dev)
 		}
 	} else {		/* IPV6 * */
 
-		if (pkt_dev->min_in6_daddr.s6_addr32[0] == 0 &&
-		    pkt_dev->min_in6_daddr.s6_addr32[1] == 0 &&
-		    pkt_dev->min_in6_daddr.s6_addr32[2] == 0 &&
-		    pkt_dev->min_in6_daddr.s6_addr32[3] == 0) ;
-		else {
+		if (!ipv6_addr_any(&pkt_dev->min_in6_daddr)) {
 			int i;
 
 			/* Only random destinations yet */
