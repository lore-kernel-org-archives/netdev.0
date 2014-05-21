From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2.57] datapath: Add basic MPLS support to kernel
Date: Thu, 22 May 2014 08:03:51 +0900
Message-ID: <20140521230351.GC19986@verge.net.au>
References: <1400195227-21265-1-git-send-email-horms@verge.net.au>
 <1400195227-21265-2-git-send-email-horms@verge.net.au>
 <CAEP_g=8ZEbx0NzCaXOc=ywiBAtejpmO4K-UzVk5uwBmEfUwZ7w@mail.gmail.com>
 <20140521153153.GB10390@verge.net.au>
 <CAEP_g=9At8jhM2ym31YeWaC9u6_O-Sq1igpER3TuYXj=KXTJNg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Ben Pfaff <blp@nicira.com>, Ravi K <rkerur@gmail.com>,
	Joe Stringer <joe@wand.net.nz>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:43120 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752332AbaEUXD4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2014 19:03:56 -0400
Content-Disposition: inline
In-Reply-To: <CAEP_g=9At8jhM2ym31YeWaC9u6_O-Sq1igpER3TuYXj=KXTJNg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 21, 2014 at 01:31:55PM -0700, Jesse Gross wrote:
> On Wed, May 21, 2014 at 8:31 AM, Simon Horman <horms@verge.net.au> wrote:
> > On Tue, May 20, 2014 at 07:30:38PM -0700, Jesse Gross wrote:
> >> On Thu, May 15, 2014 at 4:07 PM, Simon Horman <horms@verge.net.au> wrote:
> >> > diff --git a/datapath/linux/compat/include/linux/netdevice.h b/datapath/linux/compat/include/linux/netdevice.h
> >> > index d726390..0381002 100644
> >> > --- a/datapath/linux/compat/include/linux/netdevice.h
> >> > +++ b/datapath/linux/compat/include/linux/netdevice.h
> >> > +#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,38)
> >> >  #define netif_skb_features rpl_netif_skb_features
> >> >  netdev_features_t rpl_netif_skb_features(struct sk_buff *skb);
> >>
> >> Currently this function doesn't look at mpls_features. Should it for
> >> things other than TSO?
> >
> > It seems to me that rpl_netif_skb_features is only used by
> > rpl_dev_queue_xmit().
> >
> > If that is the case then I don't think it is necessary to examine
> > mpls_features, which was introduced in v3.11, as rpl_dev_queue_xmit()
> > only exists for older kernel versions.
> 
> Sorry, I actually meant for upstream. I agree that the compatibility
> code reflects current kernels as written.
> 
> It seems like the checks in dev_hard_start_xmit() won't take
> mpls_features (or the presence of MPLS) into account when deciding
> whether to emulate the offload or pass the skb directly to the NIC. In
> the GSO code itself, we look at mpls_features but if we never get
> there then it will be too late.

I am reasonably sure that when I merged the MPLS GSO code into mainline
that it worked for the case where a non-MPLS GSO packet became an MPLS GSO
packet (due to a push MPLS action). But that was a while ago and looking
over the code its not obvious to my why that case would work.

I'll do some testing an analysis and propose a fix if necessary.

Would that address your concern?
