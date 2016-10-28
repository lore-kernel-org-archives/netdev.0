From: Shrijeet Mukherjee <shm@cumulusnetworks.com>
Subject: RE: [PATCH net-next RFC WIP] Patch for XDP support for virtio_net
Date: Thu, 27 Oct 2016 17:46:46 -0700
Message-ID: <de0df2550542ea43c84cf30e0df62588@mail.gmail.com>
References: <20161026185743-mutt-send-email-mst@kernel.org>
 <20161026.125245.1630138589657247338.davem@davemloft.net> <20161026200153-mutt-send-email-mst@kernel.org>
 <20161026.131122.318218609871320141.davem@davemloft.net> <20161027105514.4c0374dd@redhat.com>
 <58126CF4.5090500@gmail.com> <49429fa1fdf77d896112528861ae3854@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: mst@redhat.com, shrijeet@gmail.com, tom@herbertland.com,
        netdev@vger.kernel.org, Roopa Prabhu <roopa@cumulusnetworks.com>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: John Fastabend <john.fastabend@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f170.google.com ([209.85.217.170]:36707 "EHLO
        mail-ua0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936219AbcJ1Aqu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 20:46:50 -0400
Received: by mail-ua0-f170.google.com with SMTP id 64so36857811uap.3
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2016 17:46:49 -0700 (PDT)
In-Reply-To: <49429fa1fdf77d896112528861ae3854@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Shrijeet Mukherjee [mailto:shm@cumulusnetworks.com]
> Sent: Thursday, October 27, 2016 5:02 PM
> To: John Fastabend <john.fastabend@gmail.com>; Jesper Dangaard Brouer
> <brouer@redhat.com>; David Miller <davem@davemloft.net>
> Cc: mst@redhat.com; shrijeet@gmail.com; tom@herbertland.com;
> netdev@vger.kernel.org; Roopa Prabhu <roopa@cumulusnetworks.com>;
> Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Subject: RE: [PATCH net-next RFC WIP] Patch for XDP support for virtio_net
>
> > >
> > > Looking at the virtio_net.c code, the function call receive_big()
> > >might actually be okay for XDP, unless the incoming packet is larger
> > >than PAGE_SIZE and thus uses several pages (via a linked list in
> > >page- private).
> > >
> > > The receive_mergeable() does not look compatible with XDP.
> > >
> >
> > Looks to me the correct conditions can be met by getting the correct
> > feature negotiation to happen, specifically no
> VIRTIO_NET_F_MRG_RXBUF
> > and one of the TSO/ECN/GSO feature bits set the big_packets flag as
> Jesper
> > notes.
> >
> > Srijeet, are you going to give this a try? I'm trying to get the
> > device
> side
> > working by the way on the vhost interface.
> >
>
> Yup, I did try it .. but it looked like the device gets to make that call
> (Unless
> someone tells me I did something wrong) If I turned that feature off in
> the
> driver it crashed (did not chase too far down that hole) but let me try
> that
> again.

Nevermind, I must have had some other issue. This does seem to work using
TSO as the function. Will spin something up to have the device export an XDP
capability which would block MERGEABLE for now and we can sort out alternate
plans later ?

>
> Wanted to consider a path, which looks like has been considered and
> discarded, but for the mergable buffers case, if we disallow edit's (no
> writes) would that be an acceptable answer ? sorry in advance for the
> repeat question, but the benefit of mergeable seems like it can be real
> for
> all packets that are not being XDP'ed .. so maybe apps can make a choice
> of
> doing a copy into a local buffer and XDP_TX from there ?
