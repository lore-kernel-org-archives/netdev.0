From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Mon, 27 Oct 2008 22:39:34 +0300
Message-ID: <20081027193933.GB2590@ioremap.net>
References: <20081025.002420.82739316.davem@davemloft.net> <Pine.LNX.4.64.0810260055070.22126@twin.jikos.cz> <1225010790.8566.22.camel@marge.simson.net> <1225011648.27415.4.camel@twins> <20081026021153.47878580.akpm@linux-foundation.org> <alpine.LNX.1.10.0810262002450.12928@jikos.suse.cz> <alpine.LNX.1.10.0810271138470.12928@jikos.suse.cz> <20081027112750.GA2771@elte.hu> <20081027113306.5b1d5898@lxorguk.ukuu.org.uk> <20081027183312.GD11494@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Jiri Kosina <jkosina@suse.cz>,
	Andrew Morton <akpm@linux-foundation.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Mike Galbraith <efault@gmx.de>,
	David Miller <davem@davemloft.net>, rjw@sisk.pl,
	s0mbre@tservice.net.ru, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cet.com.ru ([195.178.208.66]:39542 "EHLO tservice.net.ru"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751998AbYJ0Tjg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2008 15:39:36 -0400
Content-Disposition: inline
In-Reply-To: <20081027183312.GD11494@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 27, 2008 at 07:33:12PM +0100, Ingo Molnar (mingo@elte.hu) wrote:
> the best dbench results come from systems that have enough RAM to 
> cache the full working set, and a filesystem intelligent enough to not 
> insert bogus IO serialization cycles (ext3 is not such a filesystem).

My test system has 8gb for 8 clients and its performance dropped by 30%.
There is no IO load since tbech uses only network part while dbench
itself uses only disk IO. What we see right now is that usual network
server which handles mixed set of essentially small reads and writes
from the socket from multiple (8) clients suddenly lost one third of
its performance.

> The moment there's real IO it becomes harder to analyze but the same 
> basic behavior remains: the more unfair the IO scheduler, the "better" 
> dbench results we get.

Right now there is no disk IO at all. Only quite usual network and
process load.

-- 
	Evgeniy Polyakov
