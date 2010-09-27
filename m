From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: (unknown)
Date: Mon, 27 Sep 2010 14:05:00 -0600
Message-ID: <20100927200500.GB25879@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Bob Arendt <rda-x0S3BwdUo6DQT0dZR+AlfA@public.gmane.org>
To: David Stevens <dlstevens-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Bcc: 
Subject: Re: igmp: Staggered igmp report intervals for unsolicited igmp
	reports
Reply-To: 
In-Reply-To: <OF871D4733.876C9DA0-ON882577AB.006AB200-882577AB.006B6101-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

On Mon, Sep 27, 2010 at 12:32:45PM -0700, David Stevens wrote:
 
> You can, of course, add a querier (or configure it, assuming an
> attached switch supports it) and set the query interval and
> robustness count as appropriate for that network.

Presumably the IPoIB multicast router should already be the querier..
How does this help handling joins to new groups?

> As would be having those networks queue packets for hardware
> addresses they know require a delay before a transmit can
> complete. But that approach can't adversely affect already-working
> solutions for typical networks, or depart unnecessarily from
> established standard protocols.

There is no way to know when a hardware address is 'ready' in a IGMPv2
sense.. The problem with IGMPv2 and any network that doesn't flood
multicast to all nodes is that there is no way to know when all IGMPv2
listeners are listening on the group you just created.

For IGMPv2 there is a special hack in the IPoIB routers that cause
them to automatically join the IP multicast groups as they are created
so they can get the per-group IGMP messages, and this process takes
time and is completely opaque to the end nodes.

IB could emulate something like ethernet flooding by sending packets
to the permanent 'broadcast' (all-IP-endpoints) multicast group - but
it has no way to know when that is necessary and when it is not.

Sending IGMPv2 packets to the group address that is being managed
(rather than an IGMP specific group like in v3) is a design choice
that probably only works well on ethernet :(

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
