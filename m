From: David Miller <davem@davemloft.net>
Subject: bcmgenet's custom ->ndo_select_queue()
Date: Mon, 24 Feb 2014 19:32:29 -0500 (EST)
Message-ID: <20140224.193229.2076944569180242866.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48706 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751472AbaBYAca (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 19:32:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


While fixing a build warning:

drivers/net/ethernet/broadcom/genet/bcmgenet.c:2293:2: warning: initialization from incompatible pointer type [enabled by default]

I see that bcmgenet's implementation is:

	return netif_is_multiqueue(dev) ? skb->queue_mapping : 0;

That makes no sense at all.

You should only define an overriding function here if you want to do
something uniqueue, and not use the default.

If you don't assign the queue mapping, it's not even going to be
set when your select_queue method is called.  In _FACT_ that's the
reason it is called, to get the queue mapping set.

I'm just deleting this completely, I hope you don't mind.
