From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2.57] datapath: Add basic MPLS support to kernel
Date: Thu, 22 May 2014 00:26:06 +0900
Message-ID: <20140521152603.GA10390@verge.net.au>
References: <1400195227-21265-1-git-send-email-horms@verge.net.au>
 <1400195227-21265-2-git-send-email-horms@verge.net.au>
 <CAEP_g=-X=T2hJoXTV5ptZRvf1WPgYa1xusczwSR1bUYAZ5yaqA@mail.gmail.com>
 <20140520104704.GA2979@verge.net.au>
 <CAEP_g=8AkoxtsGE9CbaY_AqiWqDoV1jyqpoPaYO+BZvcTpXByg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Ben Pfaff <blp@nicira.com>, Ravi K <rkerur@gmail.com>,
	Joe Stringer <joe@wand.net.nz>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:58487 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751658AbaEUP0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2014 11:26:14 -0400
Content-Disposition: inline
In-Reply-To: <CAEP_g=8AkoxtsGE9CbaY_AqiWqDoV1jyqpoPaYO+BZvcTpXByg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 20, 2014 at 07:05:28PM -0700, Jesse Gross wrote:
> On Tue, May 20, 2014 at 3:48 AM, Simon Horman <horms@verge.net.au> wrote:
> > On Mon, May 19, 2014 at 06:34:05PM -0700, Jesse Gross wrote:
> >> On Thu, May 15, 2014 at 4:07 PM, Simon Horman <horms@verge.net.au> wrote:
> >> > diff --git a/datapath/actions.c b/datapath/actions.c
> >> > index 603c7cb..7c3ae0c 100644
> >> > --- a/datapath/actions.c
> >> > +++ b/datapath/actions.c
> >> When we set the EtherType at the bottom of the function, I don't think
> >> that it is correct in the presence of VLAN tags because it will set
> >> the outer EtherType.
> >
> > I believe this comes back to the problem we have with tag ordering. A
> > problem which after the most recent discussion of this topic I planned to
> > kick into the long grass by only allowing push MPLS actions on packets with
> > a well defined tag order.
> 
> Right, I subconsciously keep forgetting this even though I know it's there.
> 
> > This is the purpose of the white list in ovs_nla_copy_actions__().  It is
> > supposed to only push MPLS actions for flows with an IPv4, IPv6, ARP, RARP
> > or MPLS ethtype.  However, I now think that the white list likely does not
> > work for VLAN packets as their flow's ethtype will be the inner-ethtype
> > (the one inside the VLAN tag) rather than a VLAN ethtype.
> >
> > I'm unsure how you would like to handle this but one possibility would be
> > simply for push_mpls() to return an error if it is called on an skb with a
> > VLAN tag present or if the ethtype doesn't match a white list. Another is
> > to set the inner ethtype.
> 
> Can't we just look at/track flow->tci to see if there is a vlan?

Yes :)

I had been thinking in terms of OpenFlow flows and thought
this wouldn't work. But I have verified that it does with datapath flows.
