From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [RFT] fib_trie: cleanup
Date: Thu, 26 Jul 2007 12:32:05 +0200
Message-ID: <18088.30757.76332.243475@robur.slu.se>
References: <20070725040304.111550f4.akpm@linux-foundation.org>
	<20070725181557.GF3572@stusta.de>
	<20070726094648.3b7301ae@oldman>
	<20070726.014902.89039353.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, bunk@stusta.de,
	Robert.Olsson@data.slu.se, akpm@linux-foundation.org,
	paulmck@linux.vnet.ibm.com, mingo@elte.hu, josh@kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:39727 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757732AbXGZL2b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jul 2007 07:28:31 -0400
In-Reply-To: <20070726.014902.89039353.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


David Miller writes:
 > From: Stephen Hemminger <shemminger@linux-foundation.org>
 > Date: Thu, 26 Jul 2007 09:46:48 +0100
 > 
 > > Try this out:
 > >      * replace macro's with inlines
 > >      * get rid of places doing multiple evaluations of NODE_PARENT
 > 
 > No objections from me.
 > 
 > Robert?

 Fine it looks cleaner and compiles... thanks Stephen.

 BTW 
 I think might be possible improve functional/performance parts too. It's the 
 list handling I'm thinking of.

 I've observed that in most cases there is only one leaf_info in the leaf list.
 In 96% of current Internet prefixes in the router I just looked into (below). 
 So optimizing for this case could be an idea. Some variant were the leaf holds
 the leaf_info data direct could be worth testing.

 Cheers.
						--ro


 Main:
        Aver depth:     2.57
        Max depth:      6
        Leaves:         215131
        Internal nodes: 52394
          1: 27662  2: 9982  3: 8510  4: 3625  5: 1684  6: 626  7: 240  8: 64  16: 1
        Pointers: 427924
Null ptrs: 160400
Total size: 7102  kB


ip route list | wc -l 
 224649

215131/224649 = 96%
