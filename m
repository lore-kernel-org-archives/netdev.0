From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v4] net: batch skb dequeueing from softnet input_pkt_queue
Date: Thu, 22 Apr 2010 16:03:21 +0800
Message-ID: <m2n412e6f7f1004220103g140ef833wb41105a491e75ae1@mail.gmail.com>
References: <1271915513-2966-1-git-send-email-xiaosuo@gmail.com>
	<20100421231843.4c284991@nehalam> <p2i412e6f7f1004212330y6f3e2a92oa295e528afde3cd4@mail.gmail.com>
	<1271920877.7895.4757.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>, jamal <hadi@cyberus.ca>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:32888 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752684Ab0DVIDn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 04:03:43 -0400
Received: by bwz25 with SMTP id 25so9219876bwz.28
        for <netdev@vger.kernel.org>; Thu, 22 Apr 2010 01:03:41 -0700 (PDT)
In-Reply-To: <1271920877.7895.4757.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 22, 2010 at 3:21 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Jamal perf reports show lock contention but also cache line ping pong=
s.
>
> Yet, you keep a process_queue_len shared by producers and consumer.
>
> Producers want to read it, while consumer decrement it (dirtying its
> cache line) every packet, slowing down the things.
>
>
> The idea of batching is to let the consumer process its local queue w=
ith
> no impact to producers.
>
> Please remove it completely, or make the consumer zero it only at the
> end of batch processing.
>
> A cache line miss cost is about 120 cycles. Multiply it by 1 million
> packet per second...
>

OK, I'll remove it, and update the input_pkt_queue only before
process_backlog returns.


--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
