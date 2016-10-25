From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next RFC WIP] Patch for XDP support for virtio_net
Date: Mon, 24 Oct 2016 18:10:13 -0700
Message-ID: <20161025011011.GA25766@ast-mbp.thefacebook.com>
References: <1477109243-29520-1-git-send-email-shrijeet@gmail.com>
 <20161023093808.161535f3@xeon-e3>
 <CAJmoNQFJhvc4VSdTRWcTZD7T2E1LQ_2BZoMQhZM18jFH8hpQCQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Shrijeet Mukherjee <shrijeet@gmail.com>, mst@redhat.com,
        Tom Herbert <tom@herbertland.com>,
        Netdev <netdev@vger.kernel.org>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Shrijeet Mukherjee <shm@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33492 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758032AbcJYBKS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2016 21:10:18 -0400
Received: by mail-pf0-f194.google.com with SMTP id i85so17901832pfa.0
        for <netdev@vger.kernel.org>; Mon, 24 Oct 2016 18:10:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAJmoNQFJhvc4VSdTRWcTZD7T2E1LQ_2BZoMQhZM18jFH8hpQCQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 23, 2016 at 06:51:53PM -0700, Shrijeet Mukherjee wrote:
> 
> The main goal of this patch was to start that discussion. My v2 patch
> rejects the ndo op if neither of rx_mergeable or big_buffers are set.
> Does that sound like a good tradeoff ? Don't know enough about who
> turns these features off and why.
> 
> I can say that virtualbox always has the device features enabled .. so
> seems like a good tradeoff ?

If virtio can be taught to work with xdp that would be awesome.
I've looked at it from xdp prog debugging point of view, but amount of
complexity related to mergeable/big/etc was too much, so I went with e1k+xdp.
Are you sure that if mergeable/big disabled than buf is contiguous?
Also my understanding that buf is not writeable?
I don't see how to do TX either... May be it's all solvable somehow.

There was a discussion to convert raw dma buffer in mlx/intel directly
into vhost to avoid skb. This will allow host to send packets into
VMs quickly. Then if we can have fast virtio in the guest then
even more interesting use cases will be solved.
