From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] Make xfrm subsystem optional
Date: Sat, 14 Jun 2003 12:18:51 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030614101851.GA24170@wotan.suse.de>
References: <20030614091631.GA16993@wotan.suse.de> <20030614.022702.41637600.davem@redhat.com> <20030614093630.GB16993@wotan.suse.de> <20030614.023843.78709528.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ak@suse.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030614.023843.78709528.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Jun 14, 2003 at 02:38:43AM -0700, David S. Miller wrote:
>    From: Andi Kleen <ak@suse.de>
>    Date: Sat, 14 Jun 2003 11:36:30 +0200
> 
>    Also when you do use it generically you will hopefully
>    discard some old code (like the rt cache?) which may make
>    up for the additional bloat. But until that happens having
>    both even when not needed doesn't make too much sense.
>    
> The rtcache will likely be retained as a flow cache lookup
> miss handler even once we use the flowcache for all lookups.
> 
> Actually, that entire area is in flux, I still do not know the
> fate of the rtcache even without the flow cache :)

In that case you could really apply the patch. It doesn't close
any future options for you, just makes live a bit better for 
some users today.

> 
>    > How about working on making the xfrm layer more lean instead? :)
>    
>    My last proposal for this (using hlists in the hash tables) was 
>    rejected, so I don't see much chance to do this.
> 
> Because hlists cannot retain the behavior we need, specifically
> because we need the ability to add to the tail.
> 
> If it's some in-kernel-image table, why not dynamically allocate the
> table in question?

Allocating it at first lookup would be racy (would need a nasty spinlock
at least). It may be possible at first policy setup, but it's not guaranteed you 
can still get two 32K continuous areas. You could fall back to vmalloc I guess.

Allocating it at bootup would be equivalent to the current BSS allocation.

Advantage of the dynamic allocation is that it would work for vendor kernels
also.

-Andi
