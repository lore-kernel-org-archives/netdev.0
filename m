From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCHv7] add mergeable buffers support to vhost_net
Date: Mon, 3 May 2010 08:39:08 -0700
Message-ID: <OF639FB51C.80B669F0-ON88257718.0054F654-88257718.0055FB45@us.ibm.com>
References: <20100503103410.GA11113@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org,
	virtualization@lists.osdl.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:49275 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932720Ab0ECPjW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 11:39:22 -0400
In-Reply-To: <20100503103410.GA11113@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Michael S. Tsirkin" <mst@redhat.com> wrote on 05/03/2010 03:34:11 AM:

> On Wed, Apr 28, 2010 at 01:57:12PM -0700, David L Stevens wrote:
> > This patch adds mergeable receive buffer support to vhost_net.
> > 
> > Signed-off-by: David L Stevens <dlstevens@us.ibm.com>
> 
> I've been doing some more testing before sending out a pull
> request, and I see a drastic performance degradation in guest to host
> traffic when this is applied but mergeable buffers are not in used
> by userspace (existing qemu-kvm userspace).

        Actually, I wouldn't expect it to work at all; the qemu-kvm
patch (particularly the feature bit setting bug fix) is required.
Without it, I think the existing code will tell the guest to use
mergeable buffers while turning it off in vhost. That was completely
non-functional for me -- what version of qemu-kvm are you using?
        What I did to test w/o mergeable buffers is turn off the
bit in VHOST_FEATURES. I'll recheck these, but qemu-kvm definitely
must be updated; the original doesn't correctly handle feature bits.

                                                                +-DLS

