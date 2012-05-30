From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Difficulties to get 1Gbps on be2net ethernet card
Date: Wed, 30 May 2012 09:06:27 +0200
Message-ID: <1338361587.2760.94.camel@edumazet-glaptop>
References: <CAL8zT=hHAc5-wGMKgumV=K9jG6tDxzej9Dffe9UYQ24gdWQRtw@mail.gmail.com>
	 <CAL8zT=jKhRjVCdYRCerMzimxPAhP5Gi+JBBfuKjG-rfg-LMoVw@mail.gmail.com>
	 <1338360536.2760.85.camel@edumazet-glaptop>
	 <CAL8zT=h2hoTWDMpTe8P-xfm-USXD6spx8fFVmm1UXyOfuuqhZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Jean-Michel Hautbois <jhautbois@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:38986 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753743Ab2E3HGc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 03:06:32 -0400
Received: by bkcji2 with SMTP id ji2so3792934bkc.19
        for <netdev@vger.kernel.org>; Wed, 30 May 2012 00:06:31 -0700 (PDT)
In-Reply-To: <CAL8zT=h2hoTWDMpTe8P-xfm-USXD6spx8fFVmm1UXyOfuuqhZw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-30 at 08:51 +0200, Jean-Michel Hautbois wrote:
> 2012/5/30 Eric Dumazet <eric.dumazet@gmail.com>:
> > On Wed, 2012-05-30 at 08:28 +0200, Jean-Michel Hautbois wrote:
> >
> >> If this can help, setting tx queue length to 5000 seems to make the
> >> problem disappear.
> >
> > Then you should have drops at Qdisc layer (before your change to 5000)
> >
> > tc -s -d qdisc
> >
> >> I didn't specified it : MTU is 4096, UDP packets are 4000 bytes.
> >
> 
> Yes :
> qdisc mq 0: dev eth1 root
>  Sent 5710049154383 bytes 1413544639 pkt (dropped 73078, overlimits 0
> requeues 281540)
>  backlog 0b 0p requeues 281540
> 
> Why ? With a 2.6.26 kernel it works well with a tx queue length of 1000.

If you send big bursts of packets, then you need a large enough queue.

Maybe your kernel is now faster than before and queue fills faster, or
TX ring is smaller ?

ethtool -g eth0

Note that everybody try to reduce dumb queue sizes because of latencies.
