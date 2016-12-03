From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [flamebait] xdp, well meaning but pointless
Date: Sat, 3 Dec 2016 11:19:11 -0500
Message-ID: <CAF=yD-+Wx9Pkt55-dUU6dYM7P==kQoKE4YXKoFSq1yi7rY5rDA@mail.gmail.com>
References: <20161201091108.GF26507@breakpoint.cc> <20161202182233.7d78459f@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Westphal <fw@strlen.de>,
        Network Development <netdev@vger.kernel.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f196.google.com ([209.85.217.196]:35294 "EHLO
        mail-ua0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753060AbcLCQTx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 11:19:53 -0500
Received: by mail-ua0-f196.google.com with SMTP id 50so27877028uae.2
        for <netdev@vger.kernel.org>; Sat, 03 Dec 2016 08:19:52 -0800 (PST)
In-Reply-To: <20161202182233.7d78459f@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 2, 2016 at 12:22 PM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
>
> On Thu, 1 Dec 2016 10:11:08 +0100 Florian Westphal <fw@strlen.de> wrote:
>
>> In light of DPDKs existence it make a lot more sense to me to provide
>> a). a faster mmap based interface (possibly AF_PACKET based) that allows
>> to map nic directly into userspace, detaching tx/rx queue from kernel.
>>
>> John Fastabend sent something like this last year as a proof of
>> concept, iirc it was rejected because register space got exposed directly
>> to userspace.  I think we should re-consider merging netmap
>> (or something conceptually close to its design).
>
> I'm actually working in this direction, of zero-copy RX mapping packets
> into userspace.  This work is mostly related to page_pool, and I only
> plan to use XDP as a filter for selecting packets going to userspace,
> as this choice need to be taken very early.
>
> My design is here:
>  https://prototype-kernel.readthedocs.io/en/latest/vm/page_pool/design/memory_model_nic.html
>
> This is mostly about changing the memory model in the drivers, to allow
> for safely mapping pages to userspace.  (An efficient queue mechanism is
> not covered).

Virtio virtqueues are used in various other locations in the stack.
With separate memory pools and send + completion descriptor rings,
signal moderation, careful avoidance of cacheline bouncing, etc. these
seem like a good opportunity for a TPACKET_V4 format.
