From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch -next] netpoll: inverted down_trylock() test
Date: Mon, 6 May 2013 15:15:13 +0300
Message-ID: <20130506121513.GA13930@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <amwang@redhat.com>, Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:35974 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752313Ab3EFMPf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 May 2013 08:15:35 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The return value is reversed from mutex_trylock().

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index a5802a8..cec074b 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -206,7 +206,7 @@ static void netpoll_poll_dev(struct net_device *dev)
 	 * the dev_open/close paths use this to block netpoll activity
 	 * while changing device state
 	 */
-	if (!down_trylock(&ni->dev_lock))
+	if (down_trylock(&ni->dev_lock))
 		return;
 
 	if (!netif_running(dev)) {
