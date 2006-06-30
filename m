From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Thu, 29 Jun 2006 17:29:48 -0700 (PDT)
Message-ID: <20060629.172948.59656719.davem@davemloft.net>
References: <1151626099.8922.64.camel@jzny2>
	<20060629.171215.112621072.davem@davemloft.net>
	<1151627180.8922.81.camel@jzny2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, kaber@trash.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:10180
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964826AbWF3A3u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 20:29:50 -0400
To: hadi@cyberus.ca
In-Reply-To: <1151627180.8922.81.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Thu, 29 Jun 2006 20:26:20 -0400

> On Thu, 2006-29-06 at 17:12 -0700, David Miller wrote:
> > The objects around it are pointers, which are 64-bit, and thus
> > the 32-bit object gets padded out to 64-bits in the layout of
> > the struct so that the next pointer member can be properly
> > aligned.
> > 
> > It does not change the size of sk_buff at all.
> > 
> 
> I see; i take it if things were moved around that may change?

Yes.

> > > Yes, it is a bug, but:
> > > dev_hold/put dont work anymore? why do you need an ifindex instead?
> > 
> > You sure you want to do that atomic operation on every single
> > input packet, regardless of whether egress operations are
> > using it or not?
> > 
> 
> Can you avoid doing the refcount?
> Note Thomas is doing dev_get_by_index (which will do the atomic ref
> count).

He is doing that where skb->input_device is needed, which is
what we want.

> I didnt quiet follow, the ref count seems only needed in the
> redirection, no?

I'm saying that, we don't need the refcount, just setting
the skb->input_index thing, unless someone actually cares
about the input device.

As long as the packet hits not paths that care about the
SKB input device, no atomic refcounts are taken.  It's
just an integer sitting there in the SKB.
