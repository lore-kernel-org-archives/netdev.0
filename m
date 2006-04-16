From: Andi Kleen <ak@suse.de>
Subject: Re: skb diet
Date: Sun, 16 Apr 2006 17:16:31 +0200
Message-ID: <200604161716.31276.ak@suse.de>
References: <baebb9a00604150417h1ffb3f97g102253dca0b3a53e@mail.gmail.com> <200604152122.01914.ak@suse.de> <baebb9a00604160556o2abe6df1y4a185a0fd8f45e7b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:5604 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S1750747AbWDPQRv convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Apr 2006 12:17:51 -0400
To: "Hisham Kotry" <hkotry@gmail.com>
In-Reply-To: <baebb9a00604160556o2abe6df1y4a185a0fd8f45e7b@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 16 April 2006 14:56, Hisham Kotry wrote:
> > Where would that tag list be stored if you want to remove the
> > 40 bytes of ->cb?
>
> I apologize if I wasn't clear, the tag list would go in a new
> skb->tags field replacing the existsing skb->cb array, so the skb
> would lose 40-sizeof(void*) bytes wich seems reasonable to me.

This means for the common TCP case you would actually 
need more memory than before - a new pointer and overhead
from the tags. Currently we neither need pointer nor tags 
for anything.

Also you would need to complicate alloc_skb to preallocate
this memory and complicate the freeing by checking for it
and freeing it if it was allocated dynamically 
(e.g. if a later layer needed it, not the layer that first allocates
it you would need to allocate a new buffer later which would then
need to be freed) 

>
> > Linux 2.0 did something like this, but that was removed for good
> > reasons. Now TCP always clones skbs before sending it out.
>
> Do you remember what those reasons were? I couldn't find a related
> discussion in the archives. I think the BSD mbuf tags approach is
> sound enough to justify the move.

>From your description so far it seems to only have disadvantages.

> > And optimizing for uncommon cases (not TCP) doesn't seem too useful.
>
> As pointed out by Bert Hubert, there are people who have heavy traffic
> on non-tcp connections.

It's a small minority compared to TCP users.

-Andi

