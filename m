From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net: GPF in eth_header
Date: Mon, 28 Nov 2016 14:14:04 -0800
Message-ID: <1480371244.18162.91.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CACT4Y+at4Fp6i7WRggYq7M1+z1aHo=Bff63p+1DzC2SnTjuWdA@mail.gmail.com>
         <CANn89iJeWV9YnOzy4eXL4Sbcyw_kj_CA8JrfGaFxMse_MUFL6Q@mail.gmail.com>
         <CAAeHK+x48aKLcKfN2aYA1pBPr4Y4ESUvjCTu0xGPoYZuiRbaaw@mail.gmail.com>
         <1480359019.18162.79.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAAeHK+wWVp46ej0tk5mDnOHpH5Ky0+HiH9_SUqGcT0iTppLaGw@mail.gmail.com>
         <CACT4Y+Yr6UJxXosjx2FO=KtxGr40X07_UBiscs1BP1s8cTaqAA@mail.gmail.com>
         <1480362459.18162.83.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480367152.18162.86.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480367886.18162.88.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161128213444.GA9858@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Vyukov <dvyukov@google.com>,
        syzkaller <syzkaller@googlegroups.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        David Miller <davem@davemloft.net>,
        Tom Herbert <tom@herbertland.com>,
        Alexander Duyck <aduyck@mirantis.com>,
        Jiri Benc <jbenc@redhat.com>,
        Sabrina Dubroca <sd@queasysnail.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34531 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753423AbcK1WPH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 17:15:07 -0500
In-Reply-To: <20161128213444.GA9858@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-11-28 at 22:34 +0100, Florian Westphal wrote:
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > > Might be a bug added in commit daaa7d647f81f3
> > > ("netfilter: ipv6: avoid nf_iterate recursion")
> > > 
> > > Florian, what do you think of dropping a packet that presumably was
> > > mangled badly by nf_ct_frag6_queue() ?
> 
> ipv4 definitely frees malformed packets.
> In general, I think netfilter should avoid 'silent' drops if possible
> and let skb continue, but of course such skbs should not be made worse
> as what we ate to begin with...
> 
> > > (Like about 48 byte pulled :(, and/or skb->csum changed )
> 
> I think this warrants a review of ipv6 reassembly too, bug reported here
> is because ipv6 nf defrag is also done on output.


ip6_frag_queue() definitely frees bad/mangled skbs()


> Looks good, we'll need to change some of the errno return codes in
> nf_ct_frag6_gather to 0 though for this to work, which should not be too
> hard ;)

If the goal is to let buggy packets pass, then we might need to undo
changes in nf_ct_frag6_queue()
