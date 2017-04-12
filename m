From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: net/ipv4: use-after-free in ipv4_datagram_support_cmsg
Date: Wed, 12 Apr 2017 11:39:16 -0400
Message-ID: <CAF=yD-++XtWeaVmdhnrwiYLOG84JTMEuZr9mxyTRnde8vE7AFQ@mail.gmail.com>
References: <CAAeHK+ysUb+yuES_XYYPDWGrXS4VUXLmQRrD2dJTeXDPL5BKpw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:34821 "EHLO
        mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752513AbdDLPj6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 11:39:58 -0400
In-Reply-To: <CAAeHK+ysUb+yuES_XYYPDWGrXS4VUXLmQRrD2dJTeXDPL5BKpw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

===================
> BUG: KASAN: use-after-free in ipv4_datagram_support_cmsg
> net/ipv4/ip_sockglue.c:500 [inline] at addr ffff880059be0128

Thanks for the report. This is accessing skb->dev from within recvmsg() at line

        info->ipi_ifindex = skb->dev->ifindex;

Introduced in 829ae9d61165 ("net-timestamp: allow reading recv cmsg on
errqueue with origin tstamp"). At this time the device may indeed have
gone away. I'm having a look at a way to read this in the receive BH
and store the ifindex.
