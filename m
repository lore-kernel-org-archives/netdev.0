From: Chris Wright <chrisw@redhat.com>
Subject: Re: [PATCH net-next 3/3] vxlan: virtual extensible lan
Date: Mon, 24 Sep 2012 14:22:26 -0700
Message-ID: <20120924212226.GJ26494@x200.localdomain>
References: <20120924184304.727711327@vyatta.com>
 <20120924185050.162920909@vyatta.com>
 <20120924205822.GI26494@x200.localdomain>
 <20120924141133.3c97e9de@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Wright <chrisw@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24742 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750715Ab2IXVW3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2012 17:22:29 -0400
Content-Disposition: inline
In-Reply-To: <20120924141133.3c97e9de@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Stephen Hemminger (shemminger@vyatta.com) wrote:
> Chris Wright <chrisw@redhat.com> wrote:
> > > +/* Propogate ECN bits out */
> > > +static inline u8 vxlan_ecn_encap(u8 tos,
> > > +				 const struct iphdr *iph,
> > > +				 const struct sk_buff *skb)
> > > +{
> > > +	u8 inner = vxlan_get_dsfield(iph, skb);
> > > +
> > > +	return INET_ECN_encapsulate(tos, inner);
> > > +}
> > 
> > Goal is to be RFC 6040 compliant, and it looks like some edge cases aren't
> > met, for example, should drop on decap when inner is not supporting ECN
> > and outer has set CE.
> 
> The code was taken from existing GRE in Linux.
> Looks like both VXLAN and GRE need to handle that.

Right.

> > > +/* Callback from net/ipv4/udp.c to receive packets */
> > > +	/* Mark socket as an encapsulation socket. */
> > > +	udp_sk(sk)->encap_type = UDP_ENCAP_L2TPINUDP;
> > 
> > I don't think we need this particular encap_type value, just != 0
> 
> Is there any value in defining new value?

No, more the propagation of L2TP constant starts to look like cargo cult
programming.  IOW, no special meaning in this context.
