From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [RFC][ PATCH 0/3] vhost-net: Add mergeable RX buffer support	to vhost-net
Date: Wed, 3 Mar 2010 00:54:25 -0800
Message-ID: <OFF77F6422.A58B61AC-ON882576DB.002F6BA9-882576DB.0030ED4C@us.ibm.com>
References: <20100303075432.GA14034@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org, rusty@rustcorp.com.au,
	virtualization@lists.osdl.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20100303075432.GA14034@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Michael S. Tsirkin" <mst@redhat.com> wrote on 03/02/2010 11:54:32 PM:

> On Tue, Mar 02, 2010 at 04:20:03PM -0800, David Stevens wrote:
> > These patches add support for mergeable receive buffers to
> > vhost-net, allowing it to use multiple virtio buffer heads for a 
single
> > receive packet.
> >                                         +-DLS
> > 
> > 
> > Signed-off-by: David L Stevens <dlstevens@us.ibm.com>
> 
> Do you have performance numbers (both with and without mergeable buffers
> in guest)?

Michael,
        Nothing formal. I did some TCP single-stream throughput tests
and was seeing 20-25% improvement on a laptop (ie, low-end hardware).
That actually surprised me; I'd think it'd be about the same, except
maybe in a test that has mixed packet sizes. Comparisons with the
net-next kernel these patches are for showed only ~10% improvement.
        But I also see a lot of variability both among different
configurations and with the same configuration on different runs.
So, I don't feel like those numbers are very solid, and I haven't
yet done any tests on bigger hardware.

2 notes: I have a modified version of qemu to get the VHOST_FEATURES
flags, including the mergeable RX bufs flag, passed to the guest; I'll
be working with your current qemu git trees next, if any changes are
needed to support it there.
        Second, I've found a missing initialization in the patches I
sent on the list, so I'll send an updated patch 2 with the fix, and
qemu patches when they are ready (plus any code-review comments
incorporated).

                                                                +-DLS

