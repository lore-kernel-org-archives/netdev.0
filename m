From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/4] Fix checksum error when using stacked vlan
Date: Fri, 30 Jan 2015 18:04:28 -0800 (PST)
Message-ID: <20150130.180428.771210305278357485.davem@davemloft.net>
References: <1422531430-32012-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux.nics@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: makita.toshiaki@lab.ntt.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52088 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761034AbbAaCE3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 21:04:29 -0500
In-Reply-To: <1422531430-32012-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Date: Thu, 29 Jan 2015 20:37:06 +0900

> When I was testing 802.1ad, I found several drivers don't take into
> account 802.1ad or multiple vlans when retrieving L3 (IP/IPv6) or
> L4 (TCP/UDP) protocol for checksum offload.
> 
> It is mainly due to vlan_get_protocol(), which extracts ether type only
> when it is tagged with single 802.1Q. When 802.1ad is used or there are
> multiple vlans, it extracts vlan protocol and drivers cannot determine
> which L3/L4 protocol is used.
> 
> Those drivers, most of which have IP_CSUM/IPV6_CSUM features, get L3/L4
> header-offset by software, so it seems that their checksum offload works
> with multiple vlans if we can parse protocols correctly.
> (They know mac header length, and probably don't care about what is in it.)
> 
> And another thing, some of Intel's drivers seem to use skb->protocol where
> vlan_get_protocol() is more suitable.
> 
> I tested that at least igb/igbvf on I350 works with this patch set.
> 
> Note:
> We can hand a double tagged packet with CHECKSUM_PARTIAL to a HW driver
> by creating a vlan device on a bridge device and enabling vlan_filtering
> of the bridge with 802.1ad protocol.

Series applied, thank you.
