From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: Raylink/WebGear testing - ray_cs.c iomem bug?
Date: Wed, 6 Oct 2004 11:06:45 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0410061102590.8290@ppc970.osdl.org>
References: <Pine.LNX.4.58.0410061032410.8290@ppc970.osdl.org>
 <20041006105453.5f7d1888.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jgarzik@pobox.com, acme@conectiva.com.br, corey@world.std.com,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041006105453.5f7d1888.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Wed, 6 Oct 2004, David S. Miller wrote:
> 
> In the spot where this occurs, it adds both CCS_BASE and
> 'rcsindex' to the sram base, and only when rcsindex >= NUMBER_OF_CCS.
> 
> NUMBER_OF_CCS is 64, and the difference between CCS_BASE and RCS_BASE
> is 0x400 so this really doesn't account for anything.

It does, though: as I noted in my second mail (after trying to figure it
out some more) the size of both ccs and rcs is 16 bytes, so when you
offset by 64, so the difference between RCS_BASE and CCS_BASE ends up 
being exactly "NUMBER_OF_CCS*sizeof(struct ccs/rcs)", which explains how 
the base is the same, and the _index_ ends up being the one that selects 
between the two.

> I can't see how you've changed the behavior, so it should work as well
> as it did before your changes.

Agreed. I've only removed a few casts, and cleaned up some of the 
accesses, so it _should_ work the way it did before.

Of course, I _should_ be handsome, so things clearly don't always work out 
the way they should. Testing would still be appreciated.

		Linus
