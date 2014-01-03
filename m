From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: move rt_genid to different cache line
Date: Fri, 03 Jan 2014 12:04:43 -0800
Message-ID: <1388779483.12212.129.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.02.1401021155330.32674@tomh.mtv.corp.google.com>
	 <1388709534.12212.106.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+mtBx_HKz3BNF=_FRTS-a-JZj9ss5TWaJU9d=oFewZbCu1_NQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:41379 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753765AbaACUEp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 15:04:45 -0500
Received: by mail-pd0-f169.google.com with SMTP id v10so15816011pde.28
        for <netdev@vger.kernel.org>; Fri, 03 Jan 2014 12:04:45 -0800 (PST)
In-Reply-To: <CA+mtBx_HKz3BNF=_FRTS-a-JZj9ss5TWaJU9d=oFewZbCu1_NQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-01-03 at 10:01 -0800, Tom Herbert wrote:

> It seems to me you have more of an issue with prequeue itself. Maybe
> it is worth considering removing it to eliminate the disparate
> behavior between read and poll+read, but then removing a long lived
> optimization has is own pitfalls.

The prequeue stuff made sense in the old model of a few concurrent flows
and one thread per flow, where the gain was worth it. It is still
interesting if you have a single flow trying to fully utilize the
bandwidth of a 20Gbp or 40Gbp link (no dst false sharing in this case)

Nowadays, the hit ratio of prequeue mode is almost 0 on servers where
network performance of concurrent flows is an issue.

https://code.google.com/p/sockperf/ is a good step using realistic
benchmark, trying to mimic the behavior of current high performance
programs.
