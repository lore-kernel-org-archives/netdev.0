From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next?] pktgen: Use simpler test for non-zero ipv6 address
Date: Wed, 10 Oct 2012 11:42:39 -0700
Message-ID: <1349894559.2035.12.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reduces object size and should be slightly faster.

allyesconfig:

$ size net/core/pktgen.o*
   text	   data	    bss	    dec	    hex	filename
  52251	   4293	  11824	  68368	  10b10	net/core/pktgen.o.new
  52310	   4293	  11848	  68451	  10b63	net/core/pktgen.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
Found by looking for if (foo) ; tests with a perl regex

Yes Eric, it could be 2 compares instead of 4 on 64-bit
systems with HAS_EFFICIENT_UNALIGNED_ACCESS.  Maybe later
or if there are other tests that could become something
like ipv6_is_zeronet.

cheers, Joe

 net/core/pktgen.c |    9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 148e73d..3aa8417 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2422,11 +2422,10 @@ static void mod_cur_headers(struct pktgen_dev *pkt_dev)
 		}
 	} else {		/* IPV6 * */
 
-		if (pkt_dev->min_in6_daddr.s6_addr32[0] == 0 &&
-		    pkt_dev->min_in6_daddr.s6_addr32[1] == 0 &&
-		    pkt_dev->min_in6_daddr.s6_addr32[2] == 0 &&
-		    pkt_dev->min_in6_daddr.s6_addr32[3] == 0) ;
-		else {
+		if (pkt_dev->min_in6_daddr.s6_addr32[0] |
+		    pkt_dev->min_in6_daddr.s6_addr32[1] |
+		    pkt_dev->min_in6_daddr.s6_addr32[2] |
+		    pkt_dev->min_in6_daddr.s6_addr32[3]) {
 			int i;
 
 			/* Only random destinations yet */
