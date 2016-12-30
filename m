From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next] af_packet: Provide a TPACKET_V2 compatible Tx
 path for TPACKET_V3
Date: Fri, 30 Dec 2016 18:03:16 -0500
Message-ID: <20161230230316.GB31800@oracle.com>
References: <1483116853-45769-1-git-send-email-sowmini.varadhan@oracle.com>
 <CAF=yD-+CMjr_9s2wVZOQEPAP5h9jpnMe3vckYGbQ9hnQoGWFEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Network Development <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Willem de Bruijn <willemb@google.com>,
        David Miller <davem@davemloft.net>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:23770 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754584AbcL3XDf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Dec 2016 18:03:35 -0500
Content-Disposition: inline
In-Reply-To: <CAF=yD-+CMjr_9s2wVZOQEPAP5h9jpnMe3vckYGbQ9hnQoGWFEw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (12/30/16 16:33), Willem de Bruijn wrote:
> 
> Once we define the interface as equivalent to v2, we cannot redefine it to
> support v3-only features later.

What v3 only features do we think we want to support?

Tpacket_v3 went in 

  commit f6fb8f100b807378fda19e83e5ac6828b638603a
  :
  Date:   Fri Aug 19 10:18:16 2011 +0000

since then apps that want to use the Rx benefits
have to deal with this dual socket feature, where
with "one socket for super-fast rx, zero Tx".
The zero-tx part sounds like a regression to me.

If we want to have something that does block Tx,
and we cannot figure out how to retro-fit it to 
the exisiting APIs, we can always go for TPACKET_V4. 


> >  TPACKET_V2 --> TPACKET_V3:
> > -       - Flexible buffer implementation:
> > +       - Flexible buffer implementation for RX_RING:
> >                 1. Blocks can be configured with non-static frame-size
> 
> This is one of the main advantages of the v3 interface, and also

sure, and we see some marginal benefits for this, when
we try to use it for our apps. But the "marginal" part
is not worth it, if I have to use separate sockets for tx and rx.

> relevant to Tx. The current implementation does not consult
> tpacket3_hdr->tp_next_offset and would preclude adding that
> later.

When is "later"? its been 6+ years.

--Sowmini
