From: Shrijeet Mukherjee <shm@cumulusnetworks.com>
Subject: RE: [PATCH net-next RFC WIP] Patch for XDP support for virtio_net
Date: Thu, 27 Oct 2016 17:02:09 -0700
Message-ID: <49429fa1fdf77d896112528861ae3854@mail.gmail.com>
References: <20161026185743-mutt-send-email-mst@kernel.org>
 <20161026.125245.1630138589657247338.davem@davemloft.net> <20161026200153-mutt-send-email-mst@kernel.org>
 <20161026.131122.318218609871320141.davem@davemloft.net> <20161027105514.4c0374dd@redhat.com>
 <58126CF4.5090500@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: mst@redhat.com, shrijeet@gmail.com, tom@herbertland.com,
        netdev@vger.kernel.org, Roopa Prabhu <roopa@cumulusnetworks.com>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: John Fastabend <john.fastabend@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f50.google.com ([209.85.213.50]:34394 "EHLO
        mail-vk0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935144AbcJ1ACP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 20:02:15 -0400
Received: by mail-vk0-f50.google.com with SMTP id c126so29013542vkd.1
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2016 17:02:14 -0700 (PDT)
In-Reply-To: <58126CF4.5090500@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >
> > Looking at the virtio_net.c code, the function call receive_big()
> > might actually be okay for XDP, unless the incoming packet is larger
> > than PAGE_SIZE and thus uses several pages (via a linked list in page-
> >private).
> >
> > The receive_mergeable() does not look compatible with XDP.
> >
>
> Looks to me the correct conditions can be met by getting the correct
> feature negotiation to happen, specifically no VIRTIO_NET_F_MRG_RXBUF
> and one of the TSO/ECN/GSO feature bits set the big_packets flag as
Jesper
> notes.
>
> Srijeet, are you going to give this a try? I'm trying to get the device
side
> working by the way on the vhost interface.
>

Yup, I did try it .. but it looked like the device gets to make that call
(Unless someone tells me I did something wrong) If I turned that feature
off in the driver it crashed (did not chase too far down that hole) but
let me try that again.

Wanted to consider a path, which looks like has been considered and
discarded, but for the mergable buffers case, if we disallow edit's (no
writes) would that be an acceptable answer ? sorry in advance for the
repeat question, but the benefit of mergeable seems like it can be real
for all packets that are not being XDP'ed .. so maybe apps can make a
choice of doing a copy into a local buffer and XDP_TX from there ?
