From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 04/10] netpoll: Warn if more packets are processed than are budgeted
Date: Fri, 14 Mar 2014 20:47:15 -0700
Message-ID: <87k3bwp1h8.fsf_-_@xmission.com>
References: <87eh28cvi6.fsf@xmission.com>
	<20140313.152311.1995854418463980325.davem@davemloft.net>
	<87eh24uu3d.fsf_-_@xmission.com>
	<20140314.225923.61318448733570839.davem@davemloft.net>
	<87k3bwqgf7.fsf@xmission.com> <877g7wqg8e.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: stephen@networkplumber.org, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:54488 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755863AbaCODrV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 23:47:21 -0400
In-Reply-To: <877g7wqg8e.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Fri, 14 Mar 2014 20:43:13 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


There is already a warning for this case in the normal netpoll path,
but put a copy here in case how netpoll calls the poll functions
causes a differenet result.

netpoll will shortly call the napi poll routine with a budget 0 to
avoid any rx packets being processed.  As nothing does that today
we may encounter drivers that have problems so a netpoll specific
warning seems desirable.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/core/netpoll.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index d9e3d74ec9ac..2ad330e02967 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -158,6 +158,7 @@ static int poll_one_napi(struct napi_struct *napi, int budget)
 	set_bit(NAPI_STATE_NPSVC, &napi->state);
 
 	work = napi->poll(napi, budget);
+	WARN_ONCE(work > budget, "%pF exceeded budget in poll\n", napi->poll);
 	trace_napi_poll(napi);
 
 	clear_bit(NAPI_STATE_NPSVC, &napi->state);
-- 
1.7.5.4
