From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net-next PATCH v5 0/6] XDP for virtio_net
Date: Thu, 8 Dec 2016 13:08:20 -0800
Message-ID: <20161208210818.GA9799@ast-mbp.thefacebook.com>
References: <20161207200139.28121.4811.stgit@john-Precision-Tower-5810>
 <20161208.141702.1346950420275854265.davem@davemloft.net>
 <20161208193814.GA1954@ast-mbp.thefacebook.com>
 <5849C68F.7080707@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, daniel@iogearbox.net,
        mst@redhat.com, shm@cumulusnetworks.com, tgraf@suug.ch,
        john.r.fastabend@intel.com, netdev@vger.kernel.org,
        brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36670 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932277AbcLHVI0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 16:08:26 -0500
Received: by mail-pf0-f193.google.com with SMTP id c4so22799411pfb.3
        for <netdev@vger.kernel.org>; Thu, 08 Dec 2016 13:08:26 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <5849C68F.7080707@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 08, 2016 at 12:46:07PM -0800, John Fastabend wrote:
> 
> Fair enough but disabling LRO to handle the case where you "might" get
> a DDOS will hurt normal good traffic.

the xdp_pass path is not optimized right now. so even without VMs
we need some work to do. lro or not-lro is imo secondary.

> > I frankly don't see a use case where you'd want to steer a packet
> > all the way into VM just to drop them there?
> 
> VM to VM traffic is my use case. And in that model we need XDP at the
> virtio or vhost layer in case of malicious/broke/untrusted VM. I have
> some vhost patches under development for when net-next opens up again.

excellent. looking forward to vhost patches.

> > Without XDP_TX it's too crippled. adjust_head() won't be possible,
> 
> Just a nit but any reason not to support adjust_head and then XDP_PASS.
> I don't have a use case in mind but also see no reason to preclude it.

adjust_head and xdp_pass needs to be supported. No doubt.
the use case is metadata passing between xdp and upper layers.

> In summary:
> 
> I think its worth investigating getting LRO working but agree we can't
> sacrifice any of the existing features or complicate the code to do it.
> If the result of investigating is it can't be done then that is how it
> is.

agree

> Requiring XDP drivers to support all features is fine for me I can make
> the virtio queue scheme a bit more flexible. Michael might have some
> opinion on this though.

I say right now all the features are pretty much must have,
but in the future we will become selective.
Like zero-copy a page from dma into user space probably doesn't
make sense to do for virtio.
Multi-port TX from virtio into phys netdev doesn't make sense either.

> This series shouldn't be blocked by any of the above.

completely agree.
since we abandoned e1000+xdp patches, the virtio+xdp is the only
thing on the table that allows us to do convenient development
and testing of xdp programs.
We've talked about a repository of blessed xdp programs.
They all would need to be routinely and automatically tested.
So virtio+xdp is a must have feature to me.
