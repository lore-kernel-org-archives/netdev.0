From: Jon Masters <jonathan@jonmasters.org>
Subject: Re: [PATCH] netfilter: per netns nf_conntrack_cachep
Date: Tue, 02 Feb 2010 12:07:06 -0500
Message-ID: <1265130426.2861.158.camel@tonnant>
References: <1264813832.2793.446.camel@tonnant>
	 <1264816634.2793.505.camel@tonnant> <1264816777.2793.510.camel@tonnant>
	 <1264834704.2919.3.camel@edumazet-laptop>
	 <1265016745.7499.144.camel@tonnant>
	 <b6fcc0a1002010136k7e78a998p31a9e7464c2e8d44@mail.gmail.com>
	 <1265019160.2848.14.camel@edumazet-laptop>
	 <b6fcc0a1002010225u4e74f9f0q633d73038234dc37@mail.gmail.com>
	 <1265023437.2848.30.camel@edumazet-laptop>
	 <1265035970.2848.50.camel@edumazet-laptop>
	 <b6fcc0a1002010658j4f52a9b8kf10e4bb07a2f1075@mail.gmail.com>
	 <1265036548.2848.55.camel@edumazet-laptop>
	 <1265108690.2861.118.camel@tonnant>  <1265110504.2861.135.camel@tonnant>
	 <1265129192.2861.141.camel@tonnant>  <4B685756.8010107@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dallas.jonmasters.org ([72.29.103.172]:41549 "EHLO
	dallas.jonmasters.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756667Ab0BBRH0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2010 12:07:26 -0500
In-Reply-To: <4B685756.8010107@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-02-02 at 17:48 +0100, Patrick McHardy wrote:
> Jon Masters wrote:
> > On Tue, 2010-02-02 at 06:35 -0500, Jon Masters wrote:
> > 
> >> I think there's something more fundamental going on here.
> > 
> > What happens is the conntrack code attempts to free
> > nf_conntrack_untracked back into the SL[U]B cache from which it
> > allocates other ct's.
> 
> That shouldn't happen, the untracked conntrack is initialized to a
> refcount of 1, which is never released.

Ah, but I think it is :) It's also re-initialized (with an atomic_set)
every time a new namespace is created, whereas this should probably only
be done in the init_init_net code, not in init_net :)

> > There's just one problem...that's a static struct
> > not from the cache. So, this is why we end up with the SLAB being
> > corrupted and the address immediately following the
> > nf_conntrack_untracked being corrupted.
> > 
> > I shoved some debug comments into the destroy code to see if we were
> > trying to free nf_conntrack_untracked, and bingo. I have shoved a panic
> > in there now, will send you a backtrace.
> 
> Thanks.

No problem. And thanks for your help. I'm sorry if I sound frustrated at
this, it's just causing all of my test machines running KVM guests to
fall over :)

Jon.


