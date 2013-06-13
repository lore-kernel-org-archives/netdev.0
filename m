From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] datapath: Add basic MPLS support to kernel
Date: Thu, 13 Jun 2013 15:16:51 +0900
Message-ID: <20130613061651.GC15354@verge.net.au>
References: <1370851669-32400-1-git-send-email-horms@verge.net.au>
 <CAEP_g=_rC9unxv13xvEL3fpC4i2p9rcSWMo4NOeHFWHsp36QRw@mail.gmail.com>
 <CALnjE+pRpC9J91cjgeOxzp_xZ+_eB+UbtEyea13BjJ47K9Utrg@mail.gmail.com>
 <20130613011921.GA32025@verge.net.au>
 <CALnjE+rerp_+Ri107rZXFiJJ2DXs0skZHN=1K15oBJvqh5THrA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesse Gross <jesse@nicira.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Ben Pfaff <blp@nicira.com>,
	Jarno Rajahalme <jarno.rajahalme@nsn.com>,
	Joe Stringer <joe@wand.net.nz>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:56609 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750762Ab3FMGQx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 02:16:53 -0400
Content-Disposition: inline
In-Reply-To: <CALnjE+rerp_+Ri107rZXFiJJ2DXs0skZHN=1K15oBJvqh5THrA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 12, 2013 at 11:00:56PM -0700, Pravin Shelar wrote:
> On Wed, Jun 12, 2013 at 6:19 PM, Simon Horman <horms@verge.net.au> wrote:
> > On Wed, Jun 12, 2013 at 06:14:07PM -0700, Pravin Shelar wrote:
> >> On Tue, Jun 11, 2013 at 2:26 PM, Jesse Gross <jesse@nicira.com> wrote:
> >> > On Mon, Jun 10, 2013 at 1:07 AM, Simon Horman <horms@verge.net.au> wrote:
> 
> >> >> @@ -341,10 +376,14 @@ static int netdev_send(struct vport *vport, struct sk_buff *skb)
> >> >>                                 nskb = skb->next;
> >> >>                                 skb->next = NULL;
> >> >>
> >> >> -                               skb = __vlan_put_tag(skb, vlan_tx_tag_get(skb));
> >> >> +                               if (vlan)
> >> >> +                                       skb = __vlan_put_tag(skb, vlan_tx_tag_get(skb));
> >> >>                                 if (likely(skb)) {
> >> >>                                         len += skb->len;
> >> >> -                                       vlan_set_tci(skb, 0);
> >> >> +                                       if (mpls)
> >> >> +                                               skb->protocol = mpls_protocol;
> >> >> +                                       if (vlan)
> >> >> +                                               vlan_set_tci(skb, 0);
> >> >>                                         dev_queue_xmit(skb);
> >> >>                                 }
> >> >
> >> > The order of setting the protocol field is different from the one
> >> > below and I think this one isn't right because it means that the MPLS
> >> > protocol can override the vlan.
> >> >
> >> > Pravin, can you take a look at this as well since you are working in
> >> > the same area?
> >>
> >> I think this compatibility code can be moved to new compat code posted
> >> on gre-restructuring code few changes.
> >
> > Sure that sounds reasonable but I am unsure of the status of those changes
> > and I would rather not rely on something that isn't ready to merge yet.
> 
> Right. sorry abt delay.
> But I think it is much closer now and it would be alot easy to handle
> compatibility, so it is worth waiting for.

Thanks. In that case we'll try to base the next version of this
patch on your patch.
