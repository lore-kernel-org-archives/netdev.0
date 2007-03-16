From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: [PATCH] fib_trie root node settings
Date: Fri, 16 Mar 2007 12:21:38 +0100
Message-ID: <17914.32194.959040.400671@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Robert.Olsson@data.slu.se,
	Jens.Laas@data.slu.se, hans.liss@its.uu.se
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:54600 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753191AbXCPLVo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Mar 2007 07:21:44 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The threshold for root node can be more aggressive set to get
better tree compression. The new setting mekes the root grow 
from 16 to 19 bits and substansial improvemnt in Aver depth
this with the current table of 214393 prefixes 

But really the dynamic resize should need more investigation 
both in terms convergence and performance and maybe it should 
be possible to change...

Maybe just for the brave to start with or we may have to back 
this out.

----- Current -------
Main:
	Aver depth:     2.59
	Max depth:      9
	Leaves:         205530
	Internal nodes: 52634
	  1: 26507  2: 11693  3: 8007  4: 3700  5: 1776  6: 658  7: 241  8: 51  16: 1
	Pointers: 431426
Null ptrs: 173263
Total size: 6934  kB

----- With the new setting -------
Main:
	Aver depth:     2.06
	Max depth:      8
	Leaves:         205530
	Internal nodes: 48235
	  1: 23812  2: 10023  3: 8089  4: 3972  5: 2332  6: 6  19: 1
	Pointers: 815276
Null ptrs: 561512
Total size: 8330  kB


Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>


diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 7ef5948..1560c54 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -293,8 +293,8 @@ static inline void check_tnode(const struct tnode *tn)
 
 static int halve_threshold = 25;
 static int inflate_threshold = 50;
-static int halve_threshold_root = 15;
-static int inflate_threshold_root = 25; 
+static int halve_threshold_root = 8;
+static int inflate_threshold_root = 15; 
 
 
 static void __alias_free_mem(struct rcu_head *head)
