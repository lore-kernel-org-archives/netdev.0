From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net: GPF in eth_header
Date: Tue, 29 Nov 2016 08:15:14 -0800
Message-ID: <1480436114.18162.143.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CACT4Y+at4Fp6i7WRggYq7M1+z1aHo=Bff63p+1DzC2SnTjuWdA@mail.gmail.com>
         <CANn89iJeWV9YnOzy4eXL4Sbcyw_kj_CA8JrfGaFxMse_MUFL6Q@mail.gmail.com>
         <CAAeHK+x48aKLcKfN2aYA1pBPr4Y4ESUvjCTu0xGPoYZuiRbaaw@mail.gmail.com>
         <CACPEyM-4dwvmEvq3uTN_8Y-YosP8qA3cYV+oxkufFOn8M+=hew@mail.gmail.com>
         <CAAeHK+xr+GdLbLch7XatW5rifOz+=cjRCGf1ro8WxEZWziyU4Q@mail.gmail.com>
         <1480431501.18162.131.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAAeHK+zLO=Gv33TqS6tGTTC=QUYO-HOPgSB2oS1SBOAyJzPDTQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: syzkaller <syzkaller@googlegroups.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        David Miller <davem@davemloft.net>,
        Tom Herbert <tom@herbertland.com>,
        Alexander Duyck <aduyck@mirantis.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Jiri Benc <jbenc@redhat.com>,
        Sabrina Dubroca <sd@queasysnail.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36219 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753639AbcK2QPR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 11:15:17 -0500
In-Reply-To: <CAAeHK+zLO=Gv33TqS6tGTTC=QUYO-HOPgSB2oS1SBOAyJzPDTQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-11-29 at 16:31 +0100, Andrey Konovalov wrote:
=
> The issue is not with skb_network_offset(), but with __skb_pull()
> using skb_network_offset() as an argument.
> 

No. The issue can happen with _any_ __skb_pull() with a 'negative'
argument, on 64bit arches.

skb_network_offset() is only one of the many cases this could happen if
a bug is added at some random place, including memory corruption from
a different kernel layer, or buggy hardware.

> I'm not sure what would be the beast way to fix this, to add a check
> before every __skb_pull(skb_network_offset()), to fix __skb_pull() to
> work with signed ints, to add BUG_ON()'s in __skb_pull, or something
> else.
> 
> What I meant is that you fixed this very instance of the bug, and I'm
> pointing out that a similar one might hit us again.

As I said, adding a check in skb_network_offset() would not be generic
enough.

Sure, we can be proactive and add tests everywhere in the kernel, but we
also want to keep it reasonably fast.
