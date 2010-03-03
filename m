From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [RFC][ PATCH 0/3] vhost-net: Add mergeable RX buffer support	to vhost-net
Date: Wed, 3 Mar 2010 09:28:16 -0800
Message-ID: <OFFE6E21C9.265C1D67-ON882576DB.005DAD30-882576DB.005FF8F2@us.ibm.com>
References: <20100303092850.GB14034@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, rusty@rustcorp.com.au,
	virtualization@lists.osdl.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:33337 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754195Ab0CCR2i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Mar 2010 12:28:38 -0500
In-Reply-To: <20100303092850.GB14034@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Interesting. Since the feature in question is billed first of all a
> performance optimization...

By whom? Although I see some improved performance, I think its real
benefit is improving memory utilization on the guest. Instead of using
75K for an ARP packet, mergeable RX buffers only uses 4K. :-)

> Since the patches affect code paths when mergeable RX buffers are
> disabled as well, I guess the most important point would be to verify
> whether there's increase in latency and/or CPU utilization, or bandwidth
> cost when the feature bit is *disabled*.

Actually, when the feature bit is disabled, it'll only get a single
head, doesn't use the special vnet_hdr, and the codepath reduces to the
essentially to the original. But the answer is "no"; I saw no regressions
when using it without the feature bit. The only substantive difference in 
that case
is that the new code avoids copying the vnet header as the original
does, so it should actually be faster, but I don't think that's measurable
above the variability I already see.

> 
> > 2 notes: I have a modified version of qemu to get the VHOST_FEATURES
> > flags, including the mergeable RX bufs flag, passed to the guest; I'll
> > be working with your current qemu git trees next, if any changes are
> > needed to support it there.
> 
> This feature also seems to conflict with zero-copy rx patches from Xin
> Xiaohui (subject: Provide a zero-copy method on KVM virtio-net) these
> are not in a mergeable shape yet, so this is not a blocker, but I wonder
> what your thoughts on the subject are: how will we do feature
> negotiation if some backends don't support some features?

        The qemu code I have basically sends the set features and get
features all the way to vhost (ie, it's the guest negotiating with
vhost), except, of course, for the magic qemu-only bits. I think that's
the right model. I'll definitely take a look at the patch you mention
and maybe comment further.

                                                                +-DLS

