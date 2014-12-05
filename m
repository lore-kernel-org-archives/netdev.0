From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next 1/2] tcp_cubic: add SNMP counters to track how
 effective is Hystart
Date: Thu, 4 Dec 2014 19:55:45 -0500
Message-ID: <CADVnQymeqrMkco_bSPCvTguWTap3zYaX9q6Xnzq+k+yNjrQPQA@mail.gmail.com>
References: <1417738403.22424.28.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Sangtae Ha <sangtae.ha@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f180.google.com ([209.85.216.180]:60471 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932820AbaLEAzp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 19:55:45 -0500
Received: by mail-qc0-f180.google.com with SMTP id i8so13364601qcq.25
        for <netdev@vger.kernel.org>; Thu, 04 Dec 2014 16:55:45 -0800 (PST)
In-Reply-To: <1417738403.22424.28.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 4, 2014 at 7:13 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> When deploying FQ pacing, one thing we noticed is that CUBIC Hystart
> triggers too soon.
>
> Having SNMP counters to have an idea of how often the various Hystart
> methods trigger is useful prior to any modifications.
>
> This patch adds SNMP counters tracking, how many time "ack train" or
> "Delay" based Hystart triggers, and cumulative sum of cwnd at the time
> Hystart decided to end SS (Slow Start)
>
> myhost:~# nstat -a | grep Hystart
> TcpExtTCPHystartTrainDetect     9                  0.0
> TcpExtTCPHystartTrainCwnd       20650              0.0
> TcpExtTCPHystartDelayDetect     10                 0.0
> TcpExtTCPHystartDelayCwnd       360                0.0
>
> ->
>  Train detection was triggered 9 times, and average cwnd was
>  20650/9=2294,
>  Delay detection was triggered 10 times and average cwnd was 36
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

Very nice. IMHO it's great to have these as SNMP counters, so we don't
need special tools to get aggregate stats for all connections.

neal
