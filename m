From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT]: Networking
Date: Tue, 19 Aug 2008 14:21:57 -0700 (PDT)
Message-ID: <alpine.LFD.1.10.0808191411390.3324@nehalem.linux-foundation.org>
References: <alpine.LFD.1.10.0808190952000.3324@nehalem.linux-foundation.org> <20080819.131454.223684377.davem@davemloft.net> <alpine.LFD.1.10.0808191341150.3324@nehalem.linux-foundation.org> <20080819.140458.236030589.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:55720 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756023AbYHSVWA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 17:22:00 -0400
In-Reply-To: <20080819.140458.236030589.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, 19 Aug 2008, David Miller wrote:
> 
> Those fix a performance regression reported by a real user.

Since when?

The thing is, I can do a 

	gitk v2.6.24.. drivers/net/loopback.c

as well as anybody else, and TSO has not been enabled for loopback at 
least since 2.6.24. Going back to 2.6.23 (which has more changes that I 
won't comment on), it looks like that LOOPBACK_TSO thing you removed was 
there back then too.

So the performance regression if it happened must have been due to 
something else, no?

Oh, I'm sure that enabling TSO speeds things up, but apparently it also 
basically enables a code-path that hasn't been enabled since at least 
2.6.23, no?

Really, David. Was the performance regression due to something else, and 
then by enabling LOOPBACK_TSO it hid the problem? Or what? The thing is, 
-rc3 is _not_ the point to apparently change something that hasn't been 
changed in about a year (I didn't go any further back in history). 

So what's going on? Do you seriously think it's a good point in time to 
enable TSO for loopback after a long time of apparently _not_ being 
enabled? 

It smells like excuses to me. Was this really a "must be in 2.6.27" thing?

And no, it wouldn't bother me if this was a rare thing. Again, let me 
repeat: the problem is not any of the individual commits _per_se_. The 
problem is that the network layer stands out. And not in a good way. It 
stands out as being a layer that gets a _lot_ of churn late in the -rc 
game.

			Linus
