From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bonding: fix arp monitoring with vlan slaves
Date: Fri, 02 Aug 2013 15:32:12 -0700 (PDT)
Message-ID: <20130802.153212.1340051334413929810.davem@davemloft.net>
References: <1375461665-4186-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, fubar@us.ibm.com
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42573 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751670Ab3HBWcN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 18:32:13 -0400
In-Reply-To: <1375461665-4186-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Fri,  2 Aug 2013 18:41:05 +0200

> From: Nikolay Aleksandrov <Nikolay Aleksandrov nikolay@redhat.com>
> 
> When arp monitoring is enabled the bonding relies on slaves'
> dev_trans_start() value to check if the slave link is up or not, but for
> 8021q devices that value is either stale or 0, and can't be used. So use
> the 8021q's underlying device value.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>

Handling this specially in bonding isn't really ideal.

Please either hide this detail in dev_trans_start(), or (preferrably)
have vlan_dev_hard_start_xmit() set the trans_start timestamp
properly thus making this just work for everything.

Thanks.
