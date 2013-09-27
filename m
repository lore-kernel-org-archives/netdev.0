From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH] tcp: TSQ can use a dynamic limit
Date: Fri, 27 Sep 2013 11:08:28 -0400
Message-ID: <CADVnQymat61=w1QhZZc4Nfnm9cmcnT6GsRpcT5DVa-KxEwnqsQ@mail.gmail.com>
References: <20130906101635.GI14104@zion.uk.xensource.com>
	<1378472268.31445.15.camel@edumazet-glaptop>
	<522A049A.7000105@citrix.com>
	<1378486840.31445.36.camel@edumazet-glaptop>
	<1378574494.26319.14.camel@edumazet-glaptop>
	<522E4080.2050802@citrix.com>
	<1378763815.26319.39.camel@edumazet-glaptop>
	<loom.20130921T045654-573@post.gmane.org>
	<20130921150327.GA9078@zion.uk.xensource.com>
	<CAM_iQpUCGA+ifOUoyh4EuPz5sn8wUgtoD=_5dpRMuYV5aqEdxQ@mail.gmail.com>
	<1379861902.3431.12.camel@edumazet-glaptop>
	<1380277734.30872.25.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	David Miller <davem@davemloft.net>,
	Wei Liu <wei.liu2@citrix.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f49.google.com ([74.125.83.49]:41800 "EHLO
	mail-ee0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751185Ab3I0PIa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 11:08:30 -0400
Received: by mail-ee0-f49.google.com with SMTP id d41so1295577eek.36
        for <netdev@vger.kernel.org>; Fri, 27 Sep 2013 08:08:29 -0700 (PDT)
In-Reply-To: <1380277734.30872.25.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 27, 2013 at 6:28 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> When TCP Small Queues was added, we used a sysctl to limit amount of
> packets queues on Qdisc/device queues for a given TCP flow.
>
> Problem is this limit is either too big for low rates, or too small
> for high rates.
>
> Now TCP stack has rate estimation in sk->sk_pacing_rate, and TSO
> auto sizing, it can better control number of packets in Qdisc/device
> queues.
>
> New limit is two packets or at least 1 to 2 ms worth of packets.
>
> Low rates flows benefit from this patch by having even smaller
> number of packets in queues, allowing for faster recovery,
> better RTT estimations.
>
> High rates flows benefit from this patch by allowing more than 2 packets
> in flight as we had reports this was a limiting factor to reach line
> rate. [ In particular if TX completion is delayed because of coalescing
> parameters ]
>
> Example for a single flow on 10Gbp link controlled by FQ/pacing
>
> 14 packets in flight instead of 2
>
> $ tc -s -d qd
> qdisc fq 8001: dev eth0 root refcnt 32 limit 10000p flow_limit 100p
> buckets 1024 quantum 3028 initial_quantum 15140
>  Sent 1168459366606 bytes 771822841 pkt (dropped 0, overlimits 0
> requeues 6822476)
>  rate 9346Mbit 771713pps backlog 953820b 14p requeues 6822476
>   2047 flow, 2046 inactive, 1 throttled, delay 15673 ns
>   2372 gc, 0 highprio, 0 retrans, 9739249 throttled, 0 flows_plimit
>
> Note that sk_pacing_rate is currently set to twice the actual rate, but
> this might be refined in the future when a flow is in congestion
> avoidance.
>
> Additional change : skb->destructor should be set to tcp_wfree().
>
> A future patch (for linux 3.13+) might remove tcp_limit_output_bytes
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Wei Liu <wei.liu2@citrix.com>
> Cc: Cong Wang <xiyou.wangcong@gmail.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> ---

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
