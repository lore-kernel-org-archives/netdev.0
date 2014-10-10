From: Jason Baron <jbaron@akamai.com>
Subject: [PATCH net-next 0/2] macvlan: optimize receive path
Date: Fri, 10 Oct 2014 03:13:24 +0000 (GMT)
Message-ID: <cover.1412908929.git.jbaron@akamai.com>
Cc: eric.dumazet@gmail.com, stephen@networkplumber.org,
	vyasevich@gmail.com, kaber@trash.net, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay07.akamai.com ([72.246.2.115]:44574 "EHLO
	prod-mail-xrelay07.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751081AbaJJDN1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2014 23:13:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

So after porting this optimization to net-next, I found that the netperf
results of TCP_RR regress right at the maximum peak of transactions/sec. That
is as I increase the number of threads via the first argument to super_netperf,
the number of transactions/sec keep increasing, peak, and then start
decreasing. It is right at the peak, that I see a small regression with this
patch (see results in patch 2/2).

Without the patch, the ksoftirqd threads are the top cpu consumers threads on
the system, since the extra 'netif_rx()', is queuing more softirq work, whereas
with the patch, the ksoftirqd threads are below all of the 'netserver' threads 
in terms of their cpu usage. So there appears to be some interaction between how
softirqs are serviced at the peak here and this patch. I think the test results
are still supportive of this approach, but I wanted to be clear on my findings.

Thanks,

-Jason

Jason Baron (2):
  macvlan: pass 'bool' type to macvlan_count_rx()
  macvlan: optimize the receive path

 drivers/net/macvlan.c | 21 +++++++++++++--------
 1 file changed, 13 insertions(+), 8 deletions(-)

-- 
1.8.2.rc2
