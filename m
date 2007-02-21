From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Extensible hashing and RCU
Date: Thu, 22 Feb 2007 00:13:53 +0100
Message-ID: <17884.53809.880275.142372@robur.slu.se>
References: <200702201209.52388.dada1@cosmosbay.com>
	<p73y7mrd6o9.fsf@bingen.suse.de>
	<200702211419.30856.dada1@cosmosbay.com>
	<20070221.053721.112287244.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, andi@firstfloor.org, johnpol@2ka.mipt.ru,
	akepner@sgi.com, linux@horizon.com, netdev@vger.kernel.org,
	bcrl@kvack.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:41908 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1945900AbXBUXO4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Feb 2007 18:14:56 -0500
In-Reply-To: <20070221.053721.112287244.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


David Miller writes:

 > But what about if tree lookup were free :-)
 > 
 > This is why I consider Robert Olsson's trash work the most promising,
 > if we stick sockets into his full flow identified routing cache trie
 > entries, we can eliminate lookup altogether.
 > 
 > Just like how he already uses traffic inspection to kill cache entries
 > when FIN shutdown sequence is snooped, we can explicitly flush such
 > entries when socket is closed fully on local system.

 Below is current tree-stats from a "production" flowlogging application at a 
 large university (real traffic) using this full flow lookup.

 With 100k flows we typically see an aver depth 1.3 and a max depth 4. Right 
 now there is only a dst entry in leaf nodes. So yes anything else we can put 
 in leaf is "free".

trie:
        Aver depth:     1.31
        Max depth:      4
        Leaves:         99930
        Internal nodes: 14925
          1: 13450  2: 1465  3: 9  18: 1
        Pointers: 294976
Null ptrs: 180122
Total size: 7259  kB

Cheers.
						--ro
