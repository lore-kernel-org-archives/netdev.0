From: Willy Tarreau <willy@w.ods.org>
Subject: Re: [PATCH] 2.4.22-pre9-bk : bonding bug fixes
Date: Thu, 31 Jul 2003 07:03:39 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030731050339.GA24641@alpha.home.local>
References: <20030730164907.43b2d343.davem@redhat.com> <200307310022.h6V0MGjK012821@death.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, Willy Tarreau <willy@w.ods.org>,
   jgarzik@pobox.com, marcelo@conectiva.com.br, netdev@oss.sgi.com,
   bonding-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jay Vosburgh <fubar@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <200307310022.h6V0MGjK012821@death.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Jay !

On Wed, Jul 30, 2003 at 05:22:15PM -0700, Jay Vosburgh wrote:
 
> 	I've been looking at Willy's fixes, and the typo (first patch)
> and locking fix (third patch) both look good to me.  The second patch
> (the dead code warning) points out a real problem, in that the code in
> question really has no function, but the patch probably doesn't go far
> enough for a final solution (the variable that code would set,
> arp_target_hw_addr, is referenced in other places, but ends up always
> being NULL because the dead code is the only place it was ever set).
> 
> 	A more proper solution would be to simply delete the dead code
> and the arp_target_hw_addr variable, and replace the variable
> references with NULL.  This means that all of the ARP probes sent will
> be sent out as broadcasts, which is what's already happening, this
> just makes the code clearer.  Patch follows (which replaces Willy's
> second patch).
> 
> 	Does this sound reasonable to everybody?

Perfectly reasonable to me. My patch was not intended to fix it but to allow
anybody to comment on this code, which would not have been possible if I removed
it myself ;-)

IMHO, ARP probes should always be sent with broadcast addresses. We could
think about switching to unicast when we get a reply, but we must switch back
to broadcast as soon as we lose a target. This would complexify the magic which
is not absolutely necessary here.

I might send other fix propositions later (2.4.23-pre) for the ARP behaviour
(better IP source address selection, etc...) because I don't like it very much
when drivers try to find their information themselves and stick to it for all
their life (eg: my_ip). I'd like to dynamically lookup the valid source IP at
each probe (which is not *that* frequent in fact).

Cheers,
Willy
