From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] codel: add ce_threshold attribute
Date: Sat, 9 May 2015 20:23:14 -0400
Message-ID: <CADVnQy=_R5d_tHKGfoD29Znr=VzL1tHCAkD_10nnPMdMtzJU8g@mail.gmail.com>
References: <1431122712.22756.43.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Florian Westphal <fw@strlen.de>,
	Glenn Judd <glenn.judd@morganstanley.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:35090 "EHLO
	mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751658AbbEJAXP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 20:23:15 -0400
Received: by oign205 with SMTP id n205so82318866oig.2
        for <netdev@vger.kernel.org>; Sat, 09 May 2015 17:23:14 -0700 (PDT)
In-Reply-To: <1431122712.22756.43.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 8, 2015 at 6:05 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> For DCTCP or similar ECN based deployments on fabrics with shallow
> buffers, hosts are responsible for a good part of the buffering.
>
> This patch adds an optional ce_threshold to codel & fq_codel qdiscs,
> so that DCTCP can have feedback from queuing in the host.
>
> A DCTCP enabled egress port simply have a queue occupancy threshold
> above which ECT packets get CE mark.
>
> In codel language this translates to a sojourn time, so that one doesn't
> have to worry about bytes or bandwidth but delays.
>
> This makes the host an active participant in the health of the whole
> network.
>
> This also helps experimenting DCTCP in a setup without DCTCP compliant
> fabric.
>
> On following example, ce_threshold is set to 1ms, and we can see from
> 'ldelay xxx us' that TCP is not trying to go around the 5ms codel
> target.
>
> Queue has more capacity to absorb inelastic bursts (say from UDP
> traffic), as queues are maintained to an optimal level.
>
> lpaa23:~# ./tc -s -d qd sh dev eth1
> qdisc mq 1: dev eth1 root
>  Sent 87910654696 bytes 58065331 pkt (dropped 0, overlimits 0 requeues 42961)
>  backlog 3108242b 364p requeues 42961
> qdisc codel 8063: dev eth1 parent 1:1 limit 1000p target 5.0ms ce_threshold 1.0ms interval 100.0ms
>  Sent 7363778701 bytes 4863809 pkt (dropped 0, overlimits 0 requeues 5503)
>  rate 2348Mbit 193919pps backlog 255866b 46p requeues 5503
>   count 0 lastcount 0 ldelay 1.0ms drop_next 0us
>   maxpacket 68130 ecn_mark 0 drop_overlimit 0 ce_mark 72384
> qdisc codel 8064: dev eth1 parent 1:2 limit 1000p target 5.0ms ce_threshold 1.0ms interval 100.0ms
>  Sent 7636486190 bytes 5043942 pkt (dropped 0, overlimits 0 requeues 5186)
>  rate 2319Mbit 191538pps backlog 207418b 64p requeues 5186
>   count 0 lastcount 0 ldelay 694us drop_next 0us
>   maxpacket 68130 ecn_mark 0 drop_overlimit 0 ce_mark 69873
> qdisc codel 8065: dev eth1 parent 1:3 limit 1000p target 5.0ms ce_threshold 1.0ms interval 100.0ms
>  Sent 11569360142 bytes 7641602 pkt (dropped 0, overlimits 0 requeues 5554)
>  rate 3041Mbit 251096pps backlog 210446b 59p requeues 5554
>   count 0 lastcount 0 ldelay 889us drop_next 0us
>   maxpacket 68130 ecn_mark 0 drop_overlimit 0 ce_mark 37780
> ...
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Florian Westphal <fw@strlen.de>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Glenn Judd <glenn.judd@morganstanley.com>
> Cc: Nandita Dukkipati <nanditad@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> ---

Acked-by: Neal Cardwell <ncardwell@google.com>

Very nice. Thanks for doing this, Eric!

neal
