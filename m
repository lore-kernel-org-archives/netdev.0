From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: [RFC PATCH]: Dynamically sized routing cache hash table.
Date: Tue, 6 Mar 2007 14:26:04 +0100
Message-ID: <17901.27628.548105.353342@robur.slu.se>
References: <20070305.202632.74752497.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dada1@cosmosbay.com,
	robert.olsson@its.uu.se, npiggin@suse.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:47684 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030611AbXCFN0n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 08:26:43 -0500
In-Reply-To: <20070305.202632.74752497.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


David Miller writes:
 
 Interesting.
 
 > Actually, more accurately, the conflict exists in how this GC
 > logic is implemented.  The core issue is that hash table size
 > guides the GC processing, and hash table growth therefore
 > modifies those GC goals.  So with the patch below we'll just
 > keep growing the hash table instead of giving GC some time to
 > try to keep the working set in equilibrium before doing the
 > hash grow.
 
 AFIK the equilibrium is resizing function as well but using fixed 
 hash table. So can we do without equilibrium resizing if tables 
 are dynamic?  I think so....

 With the hash data structure we could monitor the average chain 
 length or just size and resize hash after that.

 > One idea is to put the hash grow check in the garbage collector,
 > and put the hash shrink check in rt_del().
 > 
 > In fact, it would be a good time to perhaps hack up some entirely
 > new passive GC logic for the routing cache.

 Could be, remeber GC in the hash chain also which was added after
 although it does's decrease the number of entries but it gives
 an upper limit. Also gc-goal must picked so it does not force 
 unwanted resizing.

 > BTW, another thing that plays into this is that Robert's TRASH work
 > could make this patch not necessary :-)

 It has "built-in" resize and chain control and the gc-goal is chosen not 
 to unnecessary resize the root node. 

 Cheers.
					--ro
