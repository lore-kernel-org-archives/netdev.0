From: David Miller <davem@davemloft.net>
Subject: bonding inactive slaves vs rx_dropped
Date: Thu, 14 Feb 2013 16:06:57 -0500 (EST)
Message-ID: <20130214.160657.1394358701071068786.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, fubar@us.ibm.com, andy@greyhouse.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60697 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759355Ab3BNVG7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 16:06:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


People are starting to notice that rx_dropped now increments on every
packet received on an bond's inactive slave.

I'm actually fine with rx_dropped incrementing in this situation.

The problem I want to address is that rx_dropped is encompassing
several unrelated situations and thus has become less useful for
diagnosis.

I think we should add some new RX stats such that we can get at
least a small amount of granularity for rx_dropped.

This way team, bond, etc. can increment a new netdev_stats->rx_foo in
this situation, and then someone doing diagnosis can see that
rx_dropped and rx_foo are incrementing at similar rates.
