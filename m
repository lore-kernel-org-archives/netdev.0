From: David Miller <davem@davemloft.net>
Subject: No more checkpatch "fixes" from newer developers.
Date: Tue, 20 Aug 2013 23:44:21 -0700 (PDT)
Message-ID: <20130820.234421.235463717243281849.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52250 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752068Ab3HUGoW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 02:44:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I've really had it with "checkpatch" fixes that break things.

Case in point, the recent ipv6 checkpatch fixes did this:

 	/* first try to inherit the link-local address from the link device */
-	if (idev->dev->iflink &&
-	    (link_dev = __dev_get_by_index(net, idev->dev->iflink))) {
-		if (!ipv6_inherit_linklocal(idev, link_dev))
+	if (idev->dev->iflink)
+		link_dev = __dev_get_by_index(net, idev->dev->iflink);
+		if (link_dev && !ipv6_inherit_linklocal(idev, link_dev))
 			return;
-	}
+

Are you kidding me?  The openning and closing curly braces that create
the basic block were erroneously removed.  Now the value of link_dev
is not defined.

I'm reverting this, and don't bother submitting these kinds of changes
any more, I'm going to ignore them.
