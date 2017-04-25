From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: Re: [RFC PATCH 3/7] net: add option to get information about
 timestamped packets
Date: Tue, 25 Apr 2017 15:56:42 +0200
Message-ID: <20170425135642.GB27148@localhost>
References: <20170412141737.5881-1-mlichvar@redhat.com>
 <20170412141737.5881-4-mlichvar@redhat.com>
 <CAF=yD-Lsbr7f7aPUsFF3gCtFdyR8yb1=VBPJGQuxv_JbrJud6Q@mail.gmail.com>
 <20170413151806.GA26613@localhost>
 <CAF=yD-+tJpY7XJrqxga=0_kn-FjS0M=yuu59m_ZRRrrcpJCbZw@mail.gmail.com>
 <20170424090043.GF8847@localhost>
 <CAF=yD-+ErPH6Qb4y9TcAMi-7X+ebxW3epq3Zxch_vrt1r3gspQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Network Development <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Denny Page <dennypage@me.com>, Jiri Benc <jbenc@redhat.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53034 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1947159AbdDYN4q (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Apr 2017 09:56:46 -0400
Content-Disposition: inline
In-Reply-To: <CAF=yD-+ErPH6Qb4y9TcAMi-7X+ebxW3epq3Zxch_vrt1r3gspQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 24, 2017 at 11:18:13AM -0400, Willem de Bruijn wrote:
> On Mon, Apr 24, 2017 at 5:00 AM, Miroslav Lichvar <mlichvar@redhat.com> wrote:
> > Would "skb->data - skb->head -
> > skb->mac_header + skb->len" always work as the L2 length for received
> > packets at the time when the cmsg is prepared?
> 
> (skb->data - skb->head) - skb->mac_header computes the length
> of data before the mac, such as reserve?

data - head includes the reserve, but mac_header does too, so I think
it should be just the length of MAC header and everything up to the
data.

> Do you mean skb->data -
> skb->mac_header (or - skb_mac_offset(skb))?

That would give me a pointer? If I used skb_mac_offset(), the total
length would be just skb->len - skb_mac_offset()?

> > As for the original ifindex, it seems to me it does need to be saved
> > to a new field since __netif_receive_skb_core() intentionally
> > overwrites skb->skb_iif. What would be the best place for it, sk_buff
> > or skb_shared_info?
> 
> Finding storage space on the receive path will not be easy.
> 
> One shortcut to avoid storing this information explicitly is to look up
> the device from skb->napi_id.

Thanks. This looks promising. It will depend on CONFIG_NET_RX_BUSY_POLL,
but I guess that's ok. It nicely isolates all costs to the timestamping
option.

-- 
Miroslav Lichvar
