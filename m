From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/16] Handle redirects just like PMTU
Date: Thu, 12 Jul 2012 01:10:30 -0700 (PDT)
Message-ID: <20120712.011030.1683311016960504439.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54724 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752759Ab2GLIKd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 04:10:33 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id BB76A5824C0
	for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 01:10:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


As described in my patch series from the other day, we need to
rearrange redirect handling so that the local initiators of packets
(sockets, tunnels, xfrms, etc.) that implement the protocols compute
the route and pass this down into the ipv4/ipv6 routing code.

These changes here do so by implementing a new dst_ops->redirect
method.

No more do we have this funny code that tries several different sets
of routing keys to try and figure out which route the redirect should
actually be applied to.

No more do we have the problem wherein TOS rewriting causes problems
for us.

Signed-off-by: David S. Miller <davem@davemloft.net>
