From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: HTB vs CoDel performance
Date: Tue, 18 Sep 2012 12:15:53 +0200
Message-ID: <1347963353.26523.224.camel@edumazet-glaptop>
References: <CAF1ivSZPpBkKk6mfhEu01bz6yP4KgJU8kK6cmeZ9e+kwH=EtiQ@mail.gmail.com>
	 <1347961511.26523.216.camel@edumazet-glaptop>
	 <CAF1ivSYweQgxbCd_ejHmDi5w7puRkE7MbpV_hczhXXDca5DJ7A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: networking <netdev@vger.kernel.org>
To: Lin Ming <mlin@ss.pku.edu.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:38551 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757124Ab2IRKP6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2012 06:15:58 -0400
Received: by bkwj10 with SMTP id j10so3033870bkw.19
        for <netdev@vger.kernel.org>; Tue, 18 Sep 2012 03:15:57 -0700 (PDT)
In-Reply-To: <CAF1ivSYweQgxbCd_ejHmDi5w7puRkE7MbpV_hczhXXDca5DJ7A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-09-18 at 17:56 +0800, Lin Ming wrote:

> I need traffic priority/traffic shaping/rate control ... actually all
> QoS features on the router.
> And if I just set the rate to gigabit(no other settings), for example,
> 
> # tc qdisc add dev eth10 root handle 20: htb default 1
> # tc class add dev eth10 parent 20 classid 20:1 htb prio 2 rate
> 1024Mbit ceil 1024Mbit burst 1281408b cburst 1281408b
> 
> it should gain similar performance as pfifo_fast.
> 
> codel has no rate control. So seems I have to find way to optimize htb?

Are you really cpu limited ? You might hit some clocks artifacts.

rate limiting to 1Gbps probably need high resolution timers.

HTB is not the only way to rate limit.
