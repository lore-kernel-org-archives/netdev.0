From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v2] net: batch skb dequeueing from softnet input_pkt_queue
Date: Tue, 13 Apr 2010 21:38:32 +0800
Message-ID: <x2z412e6f7f1004130638hb72b121cne442d722427de5a4@mail.gmail.com>
References: <1271173102-2980-1-git-send-email-xiaosuo@gmail.com>
	<1271146112.16881.213.camel@edumazet-laptop> <o2v412e6f7f1004130250rdbe17c5dr5c11c3cbbb2f6dbb@mail.gmail.com>
	<1271153942.16881.233.camel@edumazet-laptop> <n2t412e6f7f1004130553x85452fc0u22e512cad412abd3@mail.gmail.com>
	<1271164894.16881.342.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:53040 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751017Ab0DMNix convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 09:38:53 -0400
Received: by pva18 with SMTP id 18so3763671pva.19
        for <netdev@vger.kernel.org>; Tue, 13 Apr 2010 06:38:52 -0700 (PDT)
In-Reply-To: <1271164894.16881.342.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 13, 2010 at 9:21 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
>
> This is a problem of cooperation between flush_backlog() and
> process_backlog(). Dont allow flush_backlog() to return if
> process_backlog() is running. Exactly as before, but lock acquisition
> done in flush_backlog() should be a bit smarter.
>

flush_backlog() is called in IRQ context. Unless you disable irq in
process_backlog(), you can't block flush_backlog().

>
>> Oh, my GOD. When RPS is enabled, if flush_backlog(eth0) is called on
>> CPU1 when a skb0(eth0) is dequeued from CPU0's softnet and isn't
>> queued to CPU1's softnet, what will happen?
>>
>
> I am a bit lost here. flush_backlog() drops skbs, not requeue them.
>

I mean flush_backlog() don't drop all the packets, whose dev point to
a special net_device and can't be processed before the net_device
disappers.


--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
