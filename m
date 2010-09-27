From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3] xmit_compl_seq: information to reclaim vmsplice
 buffers
Date: Mon, 27 Sep 2010 21:12:37 +0200
Message-ID: <1285614757.2512.6.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1009231426450.11579@pokey.mtv.corp.google.com>
	 <20100927172315.GA8387@redhat.com>
	 <AANLkTimdrFuYONq6FvBW41AnhpA6Q+acSUmy4CiJatYL@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, sridharr@google.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:59834 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757175Ab0I0TMu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 15:12:50 -0400
Received: by wyb28 with SMTP id 28so4206040wyb.19
        for <netdev@vger.kernel.org>; Mon, 27 Sep 2010 12:12:48 -0700 (PDT)
In-Reply-To: <AANLkTimdrFuYONq6FvBW41AnhpA6Q+acSUmy4CiJatYL@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 27 septembre 2010 =C3=A0 11:38 -0700, Tom Herbert a =C3=A9crit=
 :
> >
> > Can not packets referencing this memory
> > still be outstanding at the NIC device, if retransmit happens
> > before the ack but after the packet was passed to a device?
> >
> > It's true that the reftransmit will likely get discarded
> > by the remote end, but this might be a security issue
> > if an application puts sensitive data in the buffer
> > and that gets inadvertently sent on the wire, can it not?
> >
> Yes, this hole probably does exist.  I don't know how to fix it other
> than more API that specifically reports when all references to a
> buffer are released.  In the case of TCP that probably means we'd nee=
d
> a destructor.

Hmm, thats a serious problem IMHO. This would need destructor on data,
not on skb (see previous discussion about early skb_orphan and
af_packet)

Then, it needs to handle an ordered list of packets in flight, to be
able to return the sequence of the first packet.

Alternative would be to copy data on retransmits, for tcp sockets using
SOCK_XMIT_COMPL_SEQ. (ie not using skb_clone but skb_copy())




