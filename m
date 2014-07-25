From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next 5/9] inet: frag: don't account number of
 fragment queues
Date: Fri, 25 Jul 2014 10:32:05 +0200
Message-ID: <20140725083205.GG18404@breakpoint.cc>
References: <1406213437-6155-1-git-send-email-nikolay@redhat.com>
 <1406213437-6155-6-git-send-email-nikolay@redhat.com>
 <20140724.231543.185389386835334722.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nikolay@redhat.com, netdev@vger.kernel.org, fw@strlen.de,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, alex.aring@gmail.com, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:36763 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756912AbaGYIcU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2014 04:32:20 -0400
Content-Disposition: inline
In-Reply-To: <20140724.231543.185389386835334722.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> From: Nikolay Aleksandrov <nikolay@redhat.com>
> Date: Thu, 24 Jul 2014 16:50:33 +0200
> 
> > From: Florian Westphal <fw@strlen.de>
> > 
> > The 'nqueues' counter is protected by the lru list lock,
> > once thats removed this needs to be converted to atomic
> > counter.  Given this isn't used for anything except for
> > reporting it to userspace via /proc, just remove it.
> > 
> > We still report the memory currently used by fragment
> > reassembly queues.
> > 
> > Signed-off-by: Florian Westphal <fw@strlen.de>
> 
> It's a user visible value, you can't just change it's semantics.

Really?  It won't break scripts.
In my tests this never reported any useful information to me.

If you insist, we can keep this but it seems silly to me to add atomic
ops just for this one counter which - IMO - does not provide
any useful information.
