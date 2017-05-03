From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: ipsec doesn't route TCP with 4.11 kernel
Date: Wed, 3 May 2017 10:21:29 +0200
Message-ID: <20170503082129.GM2649@secunet.com>
References: <CADJev78Cs0VBdagtfU-71pv3HHC5Vq41UXQee856aVbUqEqAYg@mail.gmail.com>
 <CAM_iQpWT5tF5+LpoTP98JNJ=440jEkxHFkn8=jtAsZgondN49A@mail.gmail.com>
 <20170427084238.GX2649@secunet.com>
 <CADJev7_=YEHmijGweqZvdATMQVuzwywEbBKweYvPurJfTEQRjQ@mail.gmail.com>
 <20170428071337.GG2649@secunet.com>
 <1493398002.31837.12.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Don Bowman <db@donbowman.ca>, Cong Wang <xiyou.wangcong@gmail.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1493398002.31837.12.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 28, 2017 at 09:46:42AM -0700, Eric Dumazet wrote:
> On Fri, 2017-04-28 at 09:13 +0200, Steffen Klassert wrote:
> >          encap type espinudp sport 4500 dport 4500 addr 0.0.0.0
> > 
> > Ok, this is espinudp. This information was important.
> 
> > This is not a GRO issue as I thought, the TX side is already broken.
> > 
> > Could you please try the patch below?
> > 
> > Subject: [PATCH] esp4: Fix udpencap for local TCP packets.
> > 
> > Locally generated TCP packets are usually cloned, so we
> > do skb_cow_data() on this packets. After that we need to
> > reload the pointer to the esp header. On udpencap this
> > header has an offset to skb_transport_header, so take this
> > offset into account.
> 
> 
> It looks like locally generated TCP packets could avoid the
> skb_cow_data(), if you were using skb_header_cloned() instead of
> skb_cloned()  ?

Yes, should be possible in the codepath where we do crypto
with separate src and dst buffers. Would require some
rearrangements to make sure we don't do inplace crypto
in this case.

Thanks for the hint!
