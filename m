From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: HTB vs CoDel performance
Date: Tue, 18 Sep 2012 11:45:11 +0200
Message-ID: <1347961511.26523.216.camel@edumazet-glaptop>
References: <CAF1ivSZPpBkKk6mfhEu01bz6yP4KgJU8kK6cmeZ9e+kwH=EtiQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: networking <netdev@vger.kernel.org>
To: Lin Ming <mlin@ss.pku.edu.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:60290 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757684Ab2IRJpQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2012 05:45:16 -0400
Received: by bkwj10 with SMTP id j10so3014473bkw.19
        for <netdev@vger.kernel.org>; Tue, 18 Sep 2012 02:45:15 -0700 (PDT)
In-Reply-To: <CAF1ivSZPpBkKk6mfhEu01bz6yP4KgJU8kK6cmeZ9e+kwH=EtiQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-09-18 at 17:28 +0800, Lin Ming wrote:
> Hi,
> 
> I'm testing htb performance on a gigabit router running 2.6.32 kernel.
> Packet path: PC1 ---> Router LAN port ---> Router WAN port ---> PC2
> 
> pfifo_fast: 920Mbps
> htb: 750Mbps, ~20% drops compared to pfifo_fast
> 
> htb tc commands as below,
> # tc qdisc add dev eth10 root handle 20: htb default 1
> # tc class add dev eth10 parent 20 classid 20:1 htb prio 2 rate
> 1024Mbit ceil 1024Mbit burst 1281408b cburst 1281408b
> 
> The performance drop seems caused by the complex htb enqueue/dequeue algorithm.
> 
> I had a quick look at CoDel code, seems it does not have so complex
> data structure as HTB.
> I'm going to backport CoDel. Is this a good choice?
> Can I gain similar performance as pfifo_fast?

codel is quite different than HTB : It has no rate control, so its very
fast. (But it has no prio differentiation as pfifo_fast with its 3
bands)

So what are your exact needs ?
