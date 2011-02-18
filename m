From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/2] Add ipv4 if addr hash.
Date: Thu, 17 Feb 2011 20:46:35 -0800 (PST)
Message-ID: <20110217.204635.71097606.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59320
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751977Ab1BREqA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 23:46:00 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 19B3824C087
	for <netdev@vger.kernel.org>; Thu, 17 Feb 2011 20:46:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


These changes are based upon something I brought up the other day,
namely that we do a full FIB lookup just to find whether a particular
unicast ipv4 address is attached to an interface.

Like ipv6, I added an RCU/RTNL protected hash table and reimplemented
__ip_dev_find() in terms of it.

These patches apply both with and without the route cache deletion
patch applied, but with the route cache removal applied the udpflood
test gets faster by ~13 seconds:

real	2m57.500s
user	0m10.640s
sys	2m46.910s

We can probably use this new table for other things as well.
