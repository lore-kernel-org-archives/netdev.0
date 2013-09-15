From: Simon Horman <horms@verge.net.au>
Subject: Re: [ovs-dev] [PATCH v2.39 0/7] MPLS actions and matches
Date: Sun, 15 Sep 2013 11:39:07 -0500
Message-ID: <20130915163906.GC14042@verge.net.au>
References: <1378711207-29890-1-git-send-email-horms@verge.net.au>
 <20130912190636.GL16044@nicira.com>
 <20130912225614.GB30229@verge.net.au>
 <20130912225439.GH25242@nicira.com>
 <CAEP_g=9ji2ihWrVuoUrcZswrOCz_f2SFeYBTwPzbB7p=ONCPUA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Pfaff <blp@nicira.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Ravi K <rkerur@gmail.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:59826 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757157Ab3IOQjK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Sep 2013 12:39:10 -0400
Content-Disposition: inline
In-Reply-To: <CAEP_g=9ji2ihWrVuoUrcZswrOCz_f2SFeYBTwPzbB7p=ONCPUA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 13, 2013 at 03:15:17PM -0700, Jesse Gross wrote:
> On Thu, Sep 12, 2013 at 3:54 PM, Ben Pfaff <blp@nicira.com> wrote:
> > On Fri, Sep 13, 2013 at 07:56:14AM +0900, Simon Horman wrote:
> >> On Thu, Sep 12, 2013 at 12:06:36PM -0700, Ben Pfaff wrote:
> >> > I've totally lost track of the status of this patch series.  I assume it
> >> > needs Jesse's review.  Jesse, if I'm wrong about that, let me know and
> >> > I'll take a pass at it.
> >>
> >> My understanding is that you have looked over the approach
> >> taken for the non-datapath code and were happy with it in
> >> the context that it needed review from Jesse along with the
> >> datapath code.
> >>
> >> I believe it was a few revisions ago that you looked over
> >> the series but I don't believe the non-datapath code has changed
> >> in a meaningful way since then.
> >
> > That sounds plausible, thanks for refreshing my memory.
> 
> I haven't really reviewed the userspace code but there is one thing in
> particular that concerns me: mpls_depth in the flow structure. We
> obviously can't be making flow-level decisions on information that the
> kernel doesn't include in the flow and I think that it is mostly
> vestigial at this point. However, at best the name seems misleading
> and at worst could result in someone trying to use information that we
> don't really have. Can we fix this somehow? Maybe using the BoS bit?

I believe we discussed this a long time ago.

The recirculation series includes a patch to allow multiple levels of pull
and push and that patch removes the mpls_depth field from the flow
structure. The approach taken is to track changes in the mpls depth during
translation, without knowing what the original depth was, and to
recirculate when the depth changes by more than one.  So in a nutshell my
strategy was to use recirculation to resolve this problem.

However, I do entirely agree with your concerns and I don't believe that we
need mpls_depth at all even at this stage.  I will take a look at removing
it by tracking the depth during translation without a dependency on
recirculation.
