From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bridge: fix lockdep addr_list_lock false positive
 splat
Date: Fri, 15 Jan 2016 15:41:45 -0500 (EST)
Message-ID: <20160115.154145.18804969118533519.davem@davemloft.net>
References: <1452881034-19128-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com,
	vyasevic@redhat.com, stephen@networkplumber.org,
	bridge@lists.linux-foundation.org, gospo@cumulusnetworks.com,
	roopa@cumulusnetworks.com
To: razor@blackwall.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33164 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751258AbcAOUls (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2016 15:41:48 -0500
In-Reply-To: <1452881034-19128-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <razor@blackwall.org>
Date: Fri, 15 Jan 2016 19:03:54 +0100

> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> After promisc mode management was introduced a bridge device could do
> dev_set_promiscuity from its ndo_change_rx_flags() callback which in
> turn can be called after the bridge's addr_list_lock has been taken
> (e.g. by dev_uc_add). This causes a false positive lockdep splat because
> the port interfaces' addr_list_lock is taken when br_manage_promisc()
> runs after the bridge's addr list lock was already taken.
> To remove the false positive introduce a custom bridge addr_list_lock
> class and set it on bridge init.
> A simple way to reproduce this is with the following:
> $ brctl addbr br0
> $ ip l add l br0 br0.100 type vlan id 100
> $ ip l set br0 up
> $ ip l set br0.100 up
> $ echo 1 > /sys/class/net/br0/bridge/vlan_filtering
> $ brctl addif br0 eth0
> Splat:
 ...
> CC: Vlad Yasevich <vyasevic@redhat.com>
> CC: Stephen Hemminger <stephen@networkplumber.org>
> CC: Bridge list <bridge@lists.linux-foundation.org>
> CC: Andy Gospodarek <gospo@cumulusnetworks.com>
> CC: Roopa Prabhu <roopa@cumulusnetworks.com>
> Fixes: 2796d0c648c9 ("bridge: Automatically manage port promiscuous mode.")
> Reported-by: Andy Gospodarek <gospo@cumulusnetworks.com>
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied and queued up for -stable, thanks Nikolay.
