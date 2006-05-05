From: George Nychis <gnychis@cmu.edu>
Subject: where i can find this netem patch?
Date: Fri, 05 May 2006 11:08:23 -0400
Message-ID: <445B6A67.7020809@cmu.edu>
References: <444FF846.7050600@cmu.edu>	<32923.128.2.140.234.1146187103.squirrel@128.2.140.234> <20060428102421.7d304ca6@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: lartc@mailman.ds9a.nl, netem@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.andrew.cmu.edu ([128.2.10.81]:17348 "EHLO
	smtp.andrew.cmu.edu") by vger.kernel.org with ESMTP
	id S1751139AbWEEPFY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 May 2006 11:05:24 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060428102421.7d304ca6@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I need help finding this patch that Stephen made.

He sent me a patch, but i do not think its related to the patch that
solved this problem.  I will include the patch he did forward to me at
the bottom.

However here is the problem, i even rtied his misspelling of change :)

thorium-ini 15849-tests # tc qdisc add dev ath0 root handle 1:0 netem
drop 0%
thorium-ini 15849-tests # tc qdisc add dev ath0 parent 1:1 handle 10:
xcp capacity 54Mbit limit 500
thorium-ini 15849-tests # tc qdisc change dev ath0 root handle 1:0 netem
drop 1%
RTNETLINK answers: Invalid argument
thorium-ini 15849-tests # tc qdisc chang dev ath0 root handle 1:0 netem
drop 1%
RTNETLINK answers: Invalid argument
thorium-ini 15849-tests # tc qdisc change dev ath0 root handle 1: netem
drop 1%
RTNETLINK answers: Invalid argument

here is the patch i was forwarded, but did not solve this problem:
--- linux-2.6.orig/net/sched/sch_netem.c
+++ linux-2.6/net/sched/sch_netem.c
@@ -167,7 +167,7 @@ static int netem_enqueue(struct sk_buff
 	if (count == 0) {
 		sch->qstats.drops++;
 		kfree_skb(skb);
-		return NET_XMIT_DROP;
+		return NET_XMIT_BYPASS;
 	}

 	/*

I'd greatly appreciate any help solving the change problem.

Thanks!
George

Stephen Hemminger wrote:
> Loss was broken, patch sent.
> 
> The following works now:
> 
> # tc qdisc add dev eth1 root handle 1:0 netem loss 20%
> 
> # tc qdisc add dev eth1 parent 1:1 handle 10: tbf \
>   rate 256kbit buffer 1600 limit 3000
> # ping -f -c 1000 shell
> 
> 1000 packets transmitted, 781 received, 21% packet loss, time 3214ms
> rtt min/avg/max/mdev = 0.187/0.398/3.763/0.730 ms, ipg/ewma 3.217/0.538 ms
> 
> # tc qdisc chang dev eth1 handle 1: netem loss 1%
> # ping -f -c 1000 shell
> 
> 1000 packets transmitted, 990 received, 1% packet loss, time 2922ms
> rtt min/avg/max/mdev = 0.187/2.739/3.298/0.789 ms, ipg/ewma 2.924/2.084 ms
> 
> 
> 
