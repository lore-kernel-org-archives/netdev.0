From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] netfilter: use per-CPU r**ursive lock {XV}
Date: Mon, 27 Apr 2009 16:32:41 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.0904271619240.22156@localhost.localdomain>
References: <49F22465.80305@gmail.com> <20090425133052.4cb711f5@nehalam> <49F4A6E3.7080102@cosmosbay.com> <20090426185646.GB29238@Krystal> <20090426145746.1184aeba@nehalam> <1240854297.7620.65.camel@twins> <20090427113010.5e3f1700@nehalam> <20090427185423.GC23862@elte.hu>
 <20090427120658.35a858bb@nehalam> <alpine.LFD.2.00.0904271219570.22156@localhost.localdomain> <20090427203616.GB3836@ioremap.net> <alpine.LFD.2.00.0904271340400.22156@localhost.localdomain> <20090427144054.1fb9b7a6@nehalam> <alpine.LFD.2.00.0904271506530.22156@localhost.localdomain>
 <alpine.LFD.2.00.0904271525120.22156@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Evgeniy Polyakov <zbr@ioremap.net>, Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <peterz@infradead.org>,
	Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>,
	Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Paul Mackerras <paulus@samba.org>, paulmck@linux.vnet.ibm.com,
	kaber@trash.net, jeff.chua.linux@gmail.com, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:41547 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752373AbZD0Xo7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 19:44:59 -0400
In-Reply-To: <alpine.LFD.2.00.0904271525120.22156@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Mon, 27 Apr 2009, Linus Torvalds wrote:
> 
> I left the commentary about "readers" and "writers", because in many
> ways it's correct, and what the code actually does is very much to
> emulate a reader-writer lock.  I put quotes around the uses in the
> comments to high-light that it largely _acts_ as a reader-writer lock. 

Btw, I think it was Paul who pointed out that technically it's probably 
better to call them "local" and "global" lockers instead of "readers" and 
"writers".

That also probably clarifies the rules on when you use one over the other 
(ie reading off all the statistics is a "global" operation, as is 
obviously replacing the tables).

Of course, "readers" and "writers" is something most Linux lock people are 
more used to. Or "brlock" for the old-timers, but that involves a heavy 
dose of bad taste. The new use is much nicer, especially since it never 
takes the global lock on _all_ cpu's (which was really a killer in so 
many ways).

			Linus
