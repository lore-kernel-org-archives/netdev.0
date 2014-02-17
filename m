From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: 802.3ad: make aggregator_identifier
 bond-private
Date: Mon, 17 Feb 2014 14:55:16 -0500 (EST)
Message-ID: <20140217.145516.1415071653420848325.davem@davemloft.net>
References: <20140214171350.GC11688@midget.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, vfalico@redhat.com, andy@greyhouse.net,
	netdev@vger.kernel.org
To: jiri@boha.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50655 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753883AbaBQTzS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 14:55:18 -0500
In-Reply-To: <20140214171350.GC11688@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Bohac <jiri@boha.cz>
Date: Fri, 14 Feb 2014 18:13:50 +0100

> aggregator_identifier is used to assign unique aggregator identifiers
> to aggregators of a bond during device enslaving.
> 
> aggregator_identifier is currently a global variable that is zeroed in
> bond_3ad_initialize().
> 
> This sequence will lead to duplicate aggregator identifiers for eth1 and eth3:
> 
> create bond0
> change bond0 mode to 802.3ad
> enslave eth0 to bond0 		//eth0 gets agg id 1
> enslave eth1 to bond0 		//eth1 gets agg id 2
> create bond1
> change bond1 mode to 802.3ad
> enslave eth2 to bond1		//aggregator_identifier is reset to 0
> 				//eth2 gets agg id 1
> enslave eth3 to bond0 		//eth3 gets agg id 2
> 
> Fix this by making aggregator_identifier private to the bond.
> 
> Signed-off-by: Jiri Bohac <jbohac@suse.cz>

Looks good, and I think this matches what the original author of this
code probably intended.

Applied and queued up for -stable, thanks.
