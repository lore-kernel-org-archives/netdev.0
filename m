From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC][ PATCH 0/3] vhost-net: Add mergeable RX buffer support
	to vhost-net
Date: Wed, 3 Mar 2010 11:28:50 +0200
Message-ID: <20100303092850.GB14034@redhat.com>
References: <20100303075432.GA14034@redhat.com> <OFF77F6422.A58B61AC-ON882576DB.002F6BA9-882576DB.0030ED4C@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org, rusty@rustcorp.com.au,
	virtualization@lists.osdl.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49849 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755315Ab0CCJc7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Mar 2010 04:32:59 -0500
Content-Disposition: inline
In-Reply-To: <OFF77F6422.A58B61AC-ON882576DB.002F6BA9-882576DB.0030ED4C@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 03, 2010 at 12:54:25AM -0800, David Stevens wrote:
> "Michael S. Tsirkin" <mst@redhat.com> wrote on 03/02/2010 11:54:32 PM:
> 
> > On Tue, Mar 02, 2010 at 04:20:03PM -0800, David Stevens wrote:
> > > These patches add support for mergeable receive buffers to
> > > vhost-net, allowing it to use multiple virtio buffer heads for a 
> single
> > > receive packet.
> > >                                         +-DLS
> > > 
> > > 
> > > Signed-off-by: David L Stevens <dlstevens@us.ibm.com>
> > 
> > Do you have performance numbers (both with and without mergeable buffers
> > in guest)?
> 
> Michael,
>         Nothing formal. I did some TCP single-stream throughput tests
> and was seeing 20-25% improvement on a laptop (ie, low-end hardware).
> That actually surprised me; I'd think it'd be about the same, except
> maybe in a test that has mixed packet sizes. Comparisons with the
> net-next kernel these patches are for showed only ~10% improvement.
>         But I also see a lot of variability both among different
> configurations and with the same configuration on different runs.
> So, I don't feel like those numbers are very solid, and I haven't
> yet done any tests on bigger hardware.

Interesting. Since the feature in question is billed first of all a
performance optimization, I think we might need some performance numbers
as a motivation.

Since the patches affect code paths when mergeable RX buffers are
disabled as well, I guess the most important point would be to verify
whether there's increase in latency and/or CPU utilization, or bandwidth
cost when the feature bit is *disabled*.

> 2 notes: I have a modified version of qemu to get the VHOST_FEATURES
> flags, including the mergeable RX bufs flag, passed to the guest; I'll
> be working with your current qemu git trees next, if any changes are
> needed to support it there.

This feature also seems to conflict with zero-copy rx patches from Xin
Xiaohui (subject: Provide a zero-copy method on KVM virtio-net) these
are not in a mergeable shape yet, so this is not a blocker, but I wonder
what your thoughts on the subject are: how will we do feature
negotiation if some backends don't support some features?

>         Second, I've found a missing initialization in the patches I
> sent on the list, so I'll send an updated patch 2 with the fix,

If you do, any chance you could use git send-email for this?

> and qemu patches when they are ready (plus any code-review comments
> incorporated).
> 

Pls take a look here as well
http://www.openfabrics.org/~mst/boring.txt

