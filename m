From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next 1/2] tcp_cubic: add SNMP counters to track how
 effective is Hystart
Date: Fri, 5 Dec 2014 01:17:54 +0100
Message-ID: <20141205001754.GG16959@breakpoint.cc>
References: <1417738403.22424.28.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Nandita Dukkipati <nanditad@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Sangtae Ha <sangtae.ha@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:39880 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752093AbaLEAR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 19:17:57 -0500
Content-Disposition: inline
In-Reply-To: <1417738403.22424.28.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
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

Alternatively we could add INET_DIAG_CUBICINFO and export such info via ss
tool.
