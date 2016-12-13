From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: "virtio-net: enable multiqueue by default" in linux-next breaks
 networking on GCE
Date: Tue, 13 Dec 2016 14:44:31 -0500
Message-ID: <20161213194431.42vtozn6bs24vwda@thunk.org>
References: <20161212233343.q5xlv55rc5npqaqp@thunk.org>
 <bb997932-20d2-42f4-0f42-bd28ae151076@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jasowang@redhat.com, netdev@vger.kernel.org, mst@redhat.com,
        nhorman@tuxdriver.com, davem@davemloft.net
To: Wei Xu <wexu@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imap.thunk.org ([74.207.234.97]:49846 "EHLO imap.thunk.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933054AbcLMToh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Dec 2016 14:44:37 -0500
Content-Disposition: inline
In-Reply-To: <bb997932-20d2-42f4-0f42-bd28ae151076@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jason's patch fixed the issue, so I think we have the proper fix, but
to answer your questions:

On Wed, Dec 14, 2016 at 01:46:44AM +0800, Wei Xu wrote:
> 
> Q1:
> Which distribution are you using for the GCE instance?

The test appliance is based on Debian Jessie.

> Q2:
> Are you running xfs test as an embedded VM case, which means XFS test
> appliance is also a VM inside the GCE instance? Or the kernel is built
> for the instance itself?

No, GCE currently doesn't support running nested VM's (e.g., running
VM's inside GCE).  So the kernel is built for the instance itself.
The way the test appliance works is that it initially boots using the
Debian Jessie default kernel and then we kexec into the kernel under
test.

> Q3:
> Can this bug be reproduced for kvm-xfstests case? I'm trying to set up
> a local test bed if it makes sense.

You definitely can't do it out of the box -- you need to build the
image using "gen-image --networking", and then run "kvm-xfstests -N
shell" as root.  But the bug doesn't reproduce on kvm-xfstests, using
a 4.9 host kernel and linux-next guest kernel.


Cheers,

					- Ted
