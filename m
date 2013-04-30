From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next 1/2] net: More fine-grained support for
 encapsulated GSO features
Date: Tue, 30 Apr 2013 12:21:22 +0900
Message-ID: <20130430032121.GC26726@verge.net.au>
References: <1366683556-4956-1-git-send-email-horms@verge.net.au>
 <1366683556-4956-2-git-send-email-horms@verge.net.au>
 <alpine.LFD.2.02.1304231354440.5598@morpheus.jf.intel.com>
 <20130425073644.GC7936@verge.net.au>
 <CAEP_g=_xZOjn6ByhM3sKw-f2Ui9kjnb1wUJ2EGBBg3GD5JnmLw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joseph Gasparakis <joseph.gasparakis@intel.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>,
	Jarno Rajahalme <jarno.rajahalme@nsn.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Maciej =?utf-8?Q?=C5=BBenczykowski?= <maze@google.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:48342 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757206Ab3D3DVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 23:21:24 -0400
Content-Disposition: inline
In-Reply-To: <CAEP_g=_xZOjn6ByhM3sKw-f2Ui9kjnb1wUJ2EGBBg3GD5JnmLw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 26, 2013 at 04:03:21PM -0700, Jesse Gross wrote:
> On Thu, Apr 25, 2013 at 12:36 AM, Simon Horman <horms@verge.net.au> wrote:
> > On Tue, Apr 23, 2013 at 02:00:19PM -0700, Joseph Gasparakis wrote:
> >> Any particular reason to introduce skb->encapsulation_features instead of
> >> using the existing skb->encapsulation? Also I don't see it used in your
> >> second patch either.
> >
> > My reasoning is that skb->encapsulation seems to alter the behaviour of
> > many different locations and I'm not sure that any of them, other than the
> > one in dev_hard_start_xmit() make sense for MPLS.
> 
> The problem is the meaning of skb->encapsulation isn't really defined
> clearly and I'm certain that the current implementation is not going
> to work in the future. Depending on your perspective, vlans, MPLS,
> tunnels, etc. can all be considered forms of encapsulation but clearly
> there are many NICs that have different capabilities across those. I
> believe the intention here was really to describe L3 tunnels as
> encapsulation, in which case MPLS really shouldn't be using this
> mechanism at all.
> 
> Now there is some overlap, especially today since most currently
> shipping silicon wasn't designed to support tunnels and so is using
> some form of offset based offloads. In that case, all forms of
> encapsulation are pretty similar. However, in the future that won't be
> the case as support for specific protocols is implemented for higher
> performance and richer support. When that happens, not only will MPLS
> and tunnels have different capabilities but various forms tunnels
> might as well.

Wouldn't be possible to describe those differences using,
dev->hw_enc_features? I assumed that was its purpose.

The intention of my patch was allow MPLS to utilise
dev->hw_enc_features without any of the other implications of
skb->encapsulation.
