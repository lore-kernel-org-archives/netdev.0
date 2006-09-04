From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Paper on lookup in Linux.
Date: Mon, 4 Sep 2006 13:43:25 +0200
Message-ID: <17660.4445.36266.884445@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: snilsson@nada.kth.se, Robert.Olsson@data.slu.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:63684 "EHLO mx1.slu.se")
	by vger.kernel.org with ESMTP id S964845AbWIDMDM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2006 08:03:12 -0400
Received: from robur.slu.se (robur.slu.se [130.238.98.12])
	by mx1.slu.se (8.13.7/8.13.6) with ESMTP id k84C3Amx001995
	for <netdev@vger.kernel.org>; Mon, 4 Sep 2006 14:03:11 +0200
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hello.

People on this list might find this paper interesting:
http://www.csc.kth.se/~snilsson/public/papers/trash/

Abstract is below. Feel free to redistribute.

Cheers.	
					--ro


TRASH - A dynamic LC-trie and hash data structure
Robert Olsson and Stefan Nilsson

A dynamic LC-trie is currently used in the Linux kernel to implement address 
lookup in the IP routing table. The main virtue of this data structure is that 
it supports both fast address lookups and frequent updates of the table. Also, 
it has an efficient memory management scheme and supports multi-processor 
architectures using the RCU locking mechanism. The structure scales nicely: 
the expected number of memory accesses for one lookup is O(log log n), where 
n is the number of entries in the lookup table. In particular, the time does 
not depend on the length of the keys, 32-bit IPv4 addresses and 128-bit 
addresses does not make a difference in this respect.

In this article we introduce TRASH, a combination of a dynamic LC-trie and a 
hash function. TRASH is a general purpose data structure supporting fast 
lookup, insert and delete operations for arbitrarily long bit strings. TRASH 
enhances the level-compression part of the LC-trie by prepending a header to 
each key. The header is a hash value based on the complete key. The extended 
keys will behave like uniformly distributed data and hence the average and 
maximum depth is typically very small, in practice less than 1.5 and 5, 
respectively.

We have implemented the scheme in the Linux kernel as a replacement for the 
dst cache (IPv4) and performed a full scale test on a production router using 
128-bit flow-based lookups. The Linux implementation of TRASH inherits the 
efficient RCU locking mechanism from the dynamic LC-trie implementation. In 
particular, the lookup time increases only marginally for longer keys and TRASH
is highly insensitive to different types of data. The performance figures are 
very promising and the cache mechanism could easily be extended to serve as a 
unified lookup for fast socket lookup, flow logging, connection tracking and 
stateful networking in general.

Keywords: trie, LC-trie, hash, hashtrie, Linux, flow lookup, garbage collection
Trita-CSC-TCS 2006:2, ISRN/KTH/CSC/TCS-2006/2-SE, ISSN 1653-7092. 

-- 
VGER BF report: U 0.830787
