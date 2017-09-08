From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Subject: Re: [PATCH iproute2] tc: fq: support low_rate_threshold attribute
Date: Fri, 8 Sep 2017 17:16:13 -0400
Message-ID: <CADAM+B17Tf3O+wakbRonuRwFFnWds9vxDeD-88cDSY0DNHx0dQ@mail.gmail.com>
References: <1504905179.15310.101.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        netdev <netdev@vger.kernel.org>,
        Neal Cardwell <ncardwell@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f47.google.com ([209.85.213.47]:33922 "EHLO
        mail-vk0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757173AbdIHVQy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 17:16:54 -0400
Received: by mail-vk0-f47.google.com with SMTP id o22so4703412vke.1
        for <netdev@vger.kernel.org>; Fri, 08 Sep 2017 14:16:54 -0700 (PDT)
In-Reply-To: <1504905179.15310.101.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 8, 2017 at 5:12 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> TCA_FQ_LOW_RATE_THRESHOLD sch_fq attribute was added in linux-4.9
>
> Tested:
>
> lpaa5:/tmp# tc -qd add dev eth1 root fq
> lpaa5:/tmp# tc -s qd sh dev eth1
> qdisc fq 8003: root refcnt 5 limit 10000p flow_limit 1000p buckets 4096 \
>  orphan_mask 4095 bands 3 priomap 1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1 quantum 3648 \
>  initial_quantum 18240 low_rate_threshold 550Kbit refill_delay 40.0ms
>  Sent 62139 bytes 395 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
>   116 flows (114 inactive, 0 throttled)
>   1 gc, 0 highprio, 0 throttled
>
> lpaa5:/tmp# ./netperf -H lpaa6 -t TCP_RR -l10 -- -q 500000 -r 300,300 -o P99_LATENCY
> 99th Percentile Latency Microseconds
> 7081
>
> lpaa5:/tmp# tc qd replace dev eth1 root fq low_rate_threshold 10Mbit
> lpaa5:/tmp# ./netperf -H lpaa6 -t TCP_RR -l10 -- -q 500000 -r 300,300 -o P99_LATENCY
> 99th Percentile Latency Microseconds
> 858
>
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: Soheil Hassas Yeganeh <soheil@google.com>

Thank you, Eric!
