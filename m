From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT]: Networking
Date: Mon, 5 Jan 2009 20:37:58 -0800 (PST)
Message-ID: <alpine.LFD.2.00.0901052029220.3057@localhost.localdomain>
References: <20090105.183106.252630446.davem@davemloft.net> <alpine.LFD.2.00.0901051839330.3057@localhost.localdomain> <20090105.201530.195720489.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:48550 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750863AbZAFEiB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2009 23:38:01 -0500
In-Reply-To: <20090105.201530.195720489.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Mon, 5 Jan 2009, David Miller wrote:
> 
> As an aside, is there a way to make git-am and other stuff using the
> git patch applying engine to take patches liberally like 'patch'
> would?

Well, "git apply" takes flags like "-C1" to accept fuzzy patches, and 
--whitespace=fix etc to apply them despite whitespace differences etc. 

And at least more modern versions of "git am" should take them and pass 
them on. Although I'd generally not encourage that much. Partly because I 
hate how often it has screwed up over the years thanks to GNU patch 
accepting any random crud.

So out of that, if I personally have a patch that only applies with fuzz 
and I know I still want to apply it, I just go and manually edit away the 
parts that no longer match in the patch itself (and fix up the line 
counts etc). But that's obviously me, and I'm very comfy editing patches 
directly.

But another quite useful approach is to just try to apply the patch to the 
version that it was done against - preferably in a separate branch - and 
then just merging the end result. 

> The default is extremely strict, which makes me check things out by
> hand.  That's good, but as I add the change by hand after verifying
> it's sanity I often make mistakes that result in things like the above
> missed delete, so if I could ask git to be non-strict it would help me
> out a lot.

Yeah, I know, "git am" really is very strict, and sometimes annoyingly so. 
But it _can_ be overridden. And if the other end uses git to generate the 
patch, you can also do a three-way apply, which really tends to work. But 
that requires that the patch have the SHA1 ID's of the original blobs (and 
that you have those blobs - ie that the patch was really generated against 
something you already had)

			Linus
