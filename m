From: Denis Kirjanov <dkirjanov@hera.kernel.org>
Subject: [PATCH] net: add rtnl assertion to linkwatch_run_queue
Date: Thu, 27 May 2010 05:51:00 +0000
Message-ID: <20100527055100.GA21234@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, shemminger@vyatta.com,
	herbert@gondor.hengli.com.au, kaber@trash.net,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:50035 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751421Ab0E0FvM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 May 2010 01:51:12 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add RTNL assertion to linkwatch_run_queue since function 
must be called with semaphore held

Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
---
net/core/link_watch.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/core/link_watch.c b/net/core/link_watch.c
index bdbce2f..e6d06c0 100644
--- a/net/core/link_watch.c
+++ b/net/core/link_watch.c
@@ -220,6 +220,7 @@ void linkwatch_forget_dev(struct net_device *dev)
 /* Must be called with the rtnl semaphore held */
 void linkwatch_run_queue(void)
 {
+	ASSERT_RTNL();
 	__linkwatch_run_queue(0);
 }
 
