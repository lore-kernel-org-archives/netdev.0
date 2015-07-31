From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Problem with fragmented packets on tun/tap interface
Date: Fri, 31 Jul 2015 13:21:35 +0200
Message-ID: <1438341695.2748.11.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAPBAu3WwLLAYtRuxrA2uDF7J5-1FPfvJ-JVB1_WHNZdf1W_M=A@mail.gmail.com>
	 <1438329395.2748.1.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAPBAu3V2Y56wnfgh1Y9gJ8XxVGEjZYaCXBNfg-uUOeYLy9NTrw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Prashant Upadhyaya <praupadhyaya@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:37427 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750904AbbGaLVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 07:21:39 -0400
Received: by wibud3 with SMTP id ud3so27735720wib.0
        for <netdev@vger.kernel.org>; Fri, 31 Jul 2015 04:21:38 -0700 (PDT)
In-Reply-To: <CAPBAu3V2Y56wnfgh1Y9gJ8XxVGEjZYaCXBNfg-uUOeYLy9NTrw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-07-31 at 16:42 +0530, Prashant Upadhyaya wrote:
> On Fri, Jul 31, 2015 at 1:26 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Fri, 2015-07-31 at 12:30 +0530, Prashant Upadhyaya wrote:
> >
> >> The delays work for me but is clearly not good for the performance of
> >> the slow path. And more importantly, I was looking for a fundamental
> >> reason regarding why it works with delays and why not without it. The
> >> issue is reproducible with a big ping (3.11.10-301.fc20.x86_64)
> >
> > How big ping needs to be to reproduce the problem ?
> >
> >
> 
> If the MTU is 1500, I start getting problems anywhere starting from
> 2900 bytes and surely comes when further big pings are used eg. 10 K.
> (ping <IP> -s <Size> eg. ping 10.3.10.244 -s 10000)
> And the big pings do work, as I said, with the delay hack.

It might help trying this while you receive such frags :

perf record -a -g skb:kfree_skb sleep 10

...

perf report
