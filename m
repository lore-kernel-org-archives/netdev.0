From: "Jan Beulich" <JBeulich@novell.com>
Subject: [PATCH] use total_highpages when calculating lowmem-only
	 allocation sizes (sctp)
Date: Mon, 06 Dec 2010 16:43:50 +0000
Message-ID: <4CFD20D60200007800026287@vpn.id2.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <akpm@linux-foundation.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For those (large) table allocations that come only from lowmem, the
total amount of memory shouldn't really matter.

Signed-off-by: Jan Beulich <jbeulich@novell.com>

---
 net/sctp/protocol.c               |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

--- linux-2.6.37-rc4/net/sctp/protocol.c
+++ 2.6.37-rc4-use-totalhigh_pages/net/sctp/protocol.c
@@ -1190,10 +1190,10 @@ SCTP_STATIC __init int sctp_init(void)
 	/* Size and allocate the association hash table.
 	 * The methodology is similar to that of the tcp hash tables.
 	 */
-	if (totalram_pages >= (128 * 1024))
-		goal = totalram_pages >> (22 - PAGE_SHIFT);
+	if (nr_pages >= (128 * 1024))
+		goal = nr_pages >> (22 - PAGE_SHIFT);
 	else
-		goal = totalram_pages >> (24 - PAGE_SHIFT);
+		goal = nr_pages >> (24 - PAGE_SHIFT);
 
 	for (order = 0; (1UL << order) < goal; order++)
 		;



