From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: [PATCH net] net: add cpu_relax to busy poll loop
Date: Sun, 25 Aug 2013 10:23:46 +0300
Message-ID: <20130825072346.31655.84970.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Eliezer Tamir <eliezer@tamir.org.il>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a cpu_relaxt to sk_busy_loop.

Julie Cummings reported performance issues when hyperthreading is on.
Arjan van de Ven observed that we should have a cpu_relax() in the
busy poll loop.

Reported-by: Julie Cummings <julie.a.cummings@intel.com>
Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
---

 include/net/busy_poll.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/net/busy_poll.h b/include/net/busy_poll.h
index 8a358a2..829627d 100644
--- a/include/net/busy_poll.h
+++ b/include/net/busy_poll.h
@@ -123,6 +123,7 @@ static inline bool sk_busy_loop(struct sock *sk, int nonblock)
 			/* local bh are disabled so it is ok to use _BH */
 			NET_ADD_STATS_BH(sock_net(sk),
 					 LINUX_MIB_BUSYPOLLRXPACKETS, rc);
+		cpu_relax();
 
 	} while (!nonblock && skb_queue_empty(&sk->sk_receive_queue) &&
 		 !need_resched() && !busy_loop_timeout(end_time));
