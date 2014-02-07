From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: remove 1ms offset in srtt computation
Date: Thu, 06 Feb 2014 22:28:15 -0800 (PST)
Message-ID: <20140206.222815.1199932808813246959.davem@davemloft.net>
References: <1391731030.10160.36.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com, ncardwell@google.com,
	valas@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40344 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750707AbaBGG2T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Feb 2014 01:28:19 -0500
In-Reply-To: <1391731030.10160.36.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 06 Feb 2014 15:57:10 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> TCP pacing depends on an accurate srtt estimation.
> 
> Current srtt estimation is using jiffie resolution,
> and has an artificial offset of at least 1 ms, which can produce
> slowdowns when FQ/pacing is used, especially in DC world,
> where typical rtt is below 1 ms.
> 
> We are planning a switch to usec resolution for linux-3.15,
> but in the meantime, this patch removes the 1 ms offset.
> 
> All we need is to have tp->srtt minimal value of 1 to differentiate
> the case of srtt being initialized or not, not 8.
> 
> The problematic behavior was observed on a 40Gbit testbed,
> where 32 concurrent netperf were reaching 12Gbps of aggregate
> speed, instead of line speed.
> 
> This patch also has the effect of reporting more accurate srtt and send
> rates to iproute2 ss command as in :
> 
> $ ss -i dst cca2
> Netid  State      Recv-Q Send-Q          Local Address:Port
> Peer Address:Port   
> tcp    ESTAB      0      0                10.244.129.1:56984
> 10.244.129.2:12865   
> 	 cubic wscale:6,6 rto:200 rtt:0.25/0.25 ato:40 mss:1448 cwnd:10 send
> 463.4Mbps rcv_rtt:1 rcv_space:29200
> tcp    ESTAB      0      390960           10.244.129.1:60247
> 10.244.129.2:50204   
> 	 cubic wscale:6,6 rto:200 rtt:0.875/0.75 mss:1448 cwnd:73 ssthresh:51
> send 966.4Mbps unacked:73 retrans:0/121 rcv_space:29200
> 
> Reported-by: Vytautas Valancius <valas@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
