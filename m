From: Dominik Kaspar <dokaspar.ietf@gmail.com>
Subject: Re: Linux TCP's Robustness to Multipath Packet Reordering
Date: Tue, 26 Apr 2011 23:04:06 +0200
Message-ID: <BANLkTint2-Fg35T9SqWPm3nOaoc1d=ZEnQ@mail.gmail.com>
References: <BANLkTimpgXCpweZKCihCQkLjSZw5zL4=Pg@mail.gmail.com>
	<1303730701.2747.110.camel@edumazet-laptop>
	<BANLkTi=xns1Gdjyt-SX3yDETSQfO23rXXg@mail.gmail.com>
	<1303850622.2699.6.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Carsten Wolff <carsten@wolffcarsten.de>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:47282 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754071Ab1DZVEH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 17:04:07 -0400
Received: by iyb14 with SMTP id 14so846784iyb.19
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2011 14:04:06 -0700 (PDT)
In-Reply-To: <1303850622.2699.6.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 26, 2011 at 10:43 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le lundi 25 avril 2011 =E0 16:35 +0200, Dominik Kaspar a =E9crit :
>
>> For the experiments, all default TCP options were used, meaning that
>> SACK, DSACK, Timestamps, were all enabled. Not sure how to turn on/o=
ff
>> TSO... so that is probably enabled, too. Path emulation is done with
>> tc/netem at the receiver interfaces (eth1, eth2) with this script:
>>
>> http://home.simula.no/~kaspar/static/netem.sh
>>
>
> What are the exact parameters ? (queue size for instance)
>
> It would be nice to give detailed stats after one run, on receiver
> (since you have netem on ingress side)
>
> tc -s -d qdisc

In these experiments, a queue size of 1000 packets was specified. I am
aware that this is typically referred to as "buffer bloat" and causes
the RTT and the cwnd to grow excessively. The smaller I configure the
queues, the more time it takes for TCP to "level up" to the aggregate
throughput. By keeping the queues so large, I hope to more quickly
identify the reason why TCP is actually able to adjust to the immense
multipath reordering. What parameters could be highly relevant, other
than the queue size?

Thanks for the tip about printing tc/netem statistics after each run,
I will use "tc -s -d qdisc" next time.

Greetings,
Dominik
