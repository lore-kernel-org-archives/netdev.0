From: Dave Dillow <dave@thedillows.org>
Subject: Re: Ethtool offload patch
Date: Tue, 04 Jan 2005 14:04:31 -0500
Message-ID: <1104865471.9860.16.camel@dillow.idleaire.com>
References: <1104396895.5845.1.camel@ori.thedillows.org>
	 <20050104094423.2d404759.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050104094423.2d404759.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2005-01-04 at 12:44, David S. Miller wrote:
> On Thu, 30 Dec 2004 03:54:55 -0500
> David Dillow <dave@thedillows.org> wrote:
> 
> > The attached patch allows the ethtool userspace tool to query and
> > control IPSEC crypto offload.
> 
> Aren't you going to need something much more sophisticated
> than a boolean on/off value?  How can I tell the driver
> "offload 3DES ESP, but not AH at all" or something like
> that?

Sure, but this was quicker. :)

Actually, I thought that would be better suited to the xfrm_user/pf_key
interfaces, perhaps using a flag on the SA that says "do not offload
me", or perhaps the opposite. I'd probably want to add a flag to
indicate which ones were actually offloaded as well so "ip xfrm state"
could give an overview of what is currently offloaded.

I know you just got back from vacation, so when you get a chance, I'd
welcome comments on the patch series -- I did most of it simply, just to
see how it would perform. There is (obviously) still work to do -- I
need to figure out how to determine if an IPv6 address is local, and it
may be nice to have some sort of LRU list to offload the most active SAs
when resources get low on the card.

The current version I'm testing includes the changes suggested on the
board (change afinfo->map_direction() and remove xfrm_bundle_list), as
well as a change to call dev->xfrm_state_add() and
dev->xfrm_bundle_add() from process context, so I can get rid of the
GFP_ATOMIC allocations.

I'll have that out as soon as I can test and rediff everything, but in
the meantime, is the whole idea fatally flawed?
-- 
Dave Dillow <dave@thedillows.org>
