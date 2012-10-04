From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 3/3] vxlan: virtual extensible lan
Date: Wed, 3 Oct 2012 21:02:20 -0700
Message-ID: <20121003210220.5e74aa5d@nehalam.linuxnetplumber.net>
References: <20121001223232.566037595@vyatta.com>
	<20121001223254.349753999@vyatta.com>
	<CAEP_g=9Y3MmsABQJyi508FEgs4635tnaVqk4Ncwbpm41bLskhg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50547 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750726Ab2JDEDB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Oct 2012 00:03:01 -0400
In-Reply-To: <CAEP_g=9Y3MmsABQJyi508FEgs4635tnaVqk4Ncwbpm41bLskhg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 3 Oct 2012 18:54:46 -0700
Jesse Gross <jesse@nicira.com> wrote:

> On Mon, Oct 1, 2012 at 3:32 PM, Stephen Hemminger <shemminger@vyatta.com> wrote:
> > --- /dev/null   1970-01-01 00:00:00.000000000 +0000
> > +++ b/drivers/net/vxlan.c       2012-10-01 15:08:38.024499080 -0700
> > +/* Transmit local packets over Vxlan
> > + *
> > + * Outer IP header inherits ECN and DF from inner header.
> > + * Outer UDP destination is the VXLAN assigned port.
> > + *           source port is based on hash of flow if available
> > + *                       otherwise use a random value
> > + */
> > +static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
> [...]
> > +       hash = skb_get_rxhash(skb);
> [...]
> > +       uh->dest = htons(vxlan_port);
> > +       uh->source = hash ? :random32();
> 
> I think this may lead to packet reordering in some cases.  If the
> protocol is unknown then it may still represent part of a flow and
> random source ports could lead to taking different paths.
> 
> Also, does it make sense to restrict the range of ports to, say, the
> upper half of the range?

Since port is always a pair, there is no need to restrict range, unless
there was a broken firewall in the way. One bug there is that random32()
can return 0 which is not a valid port number.  A better fallback
would be a hash of the MAC header.
