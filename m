From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v5 0/6] XDP for virtio_net
Date: Thu, 08 Dec 2016 14:17:02 -0500 (EST)
Message-ID: <20161208.141702.1346950420275854265.davem@davemloft.net>
References: <20161207200139.28121.4811.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, mst@redhat.com, shm@cumulusnetworks.com,
        tgraf@suug.ch, alexei.starovoitov@gmail.com,
        john.r.fastabend@intel.com, netdev@vger.kernel.org,
        brouer@redhat.com
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37150 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752246AbcLHTRJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 14:17:09 -0500
In-Reply-To: <20161207200139.28121.4811.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Wed, 07 Dec 2016 12:10:47 -0800

> This implements virtio_net for the mergeable buffers and big_packet
> modes. I tested this with vhost_net running on qemu and did not see
> any issues. For testing num_buf > 1 I added a hack to vhost driver
> to only but 100 bytes per buffer.
 ...

So where are we with this?

I'm not too thrilled with the idea of making XDP_TX optional or
something like that.  If someone enables XDP, there is a tradeoff.

I also have reservations about the idea to make jumbo frames work
without giving XDP access to the whole packet.  If it wants to push or
pop a header, it might need to know the whole packet length.  How will
you pass that to the XDP program?

Some kinds of encapsulation require trailers, thus preclusing access
to the entire packet precludes those kinds of transformations.

This is why we want simple, linear, buffer access for XDP.

Even the most seemingly minor exception turns into a huge complicated
mess.
