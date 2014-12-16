From: David Miller <davem@davemloft.net>
Subject: FIXED_PHY is broken...
Date: Tue, 16 Dec 2014 11:25:34 -0500 (EST)
Message-ID: <20141216.112534.1684849738404064350.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53442 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751008AbaLPQZh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 11:25:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I get this now when I run oldconfig:

warning: (NET_DSA_BCM_SF2 && BCMGENET && SYSTEMPORT) selects FIXED_PHY which has unmet direct dependencies (NETDEVICES && PHYLIB=y)

For the thousandth time, you cannot select Kconfig options which have
dependencies of any kind, because select does not recursively cause
dependencies to be enabled up to the root of the Kconfig tree.

If you select on something which has a "depends on", stop right there
because you can't do it.

It only works for pure leaf Kconfig nodes with no deps.

All you needed to do in order to test this was do an allmodconfig
build.
