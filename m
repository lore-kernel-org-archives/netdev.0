From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 2/9] netpoll: Visit all napi handlers in poll_napi
Date: Fri, 14 Mar 2014 18:32:09 -0700
Message-ID: <8738ikuu06.fsf_-_@xmission.com>
References: <1394540961.21721.22.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140311082312.5ad00119@nehalam.linuxnetplumber.net>
	<87eh28cvi6.fsf@xmission.com>
	<20140313.152311.1995854418463980325.davem@davemloft.net>
	<87eh24uu3d.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: stephen@networkplumber.org, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:39170 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755418AbaCOBcP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 21:32:15 -0400
In-Reply-To: <87eh24uu3d.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Fri, 14 Mar 2014 18:30:14 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In poll_napi loop through all of the napi handlers even when the
budget falls to 0 to ensure that we process all of the tx_queues, and
so that we continue to call into drivers when our initial budget is 0.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/core/netpoll.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 147c75855c9b..d9e3d74ec9ac 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -174,9 +174,6 @@ static void poll_napi(struct net_device *dev, int budget)
 		    spin_trylock(&napi->poll_lock)) {
 			budget = poll_one_napi(napi, budget);
 			spin_unlock(&napi->poll_lock);
-
-			if (!budget)
-				break;
 		}
 	}
 }
-- 
1.7.5.4
