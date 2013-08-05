From: David Miller <davem@davemloft.net>
Subject: Re: [net-next,1/3] bonding: fix vlan 0 addition and removal
Date: Mon, 05 Aug 2013 16:08:22 -0700 (PDT)
Message-ID: <20130805.160822.47868741818443064.davem@davemloft.net>
References: <1375709304-16778-2-git-send-email-nikolay@redhat.com>
	<20130805215126.GB3859@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nikolay@redhat.com, netdev@vger.kernel.org, fubar@us.ibm.com,
	andy@greyhouse.net, kaber@trash.net
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50737 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754535Ab3HEXIZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 19:08:25 -0400
In-Reply-To: <20130805215126.GB3859@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Mon, 5 Aug 2013 23:51:26 +0200

> @@ -69,7 +69,6 @@
>  #include <net/arp.h>
>  #include <linux/mii.h>
>  #include <linux/ethtool.h>
> -#include <linux/if_vlan.h>
>  #include <linux/if_bonding.h>
>  #include <linux/jiffies.h>
>  #include <linux/preempt.h>
> @@ -1976,7 +1975,7 @@ static int __bond_release_one(struct net_device
> *bond_dev,
>  		bond_set_carrier(bond);
>  		eth_hw_addr_random(bond_dev);
>  -		if (bond_vlan_used(bond)) {
> +		if (vlan_uses_dev(bond_dev)) {

If you're adding a use of vlan_uses_dev(), you should retain the
if_vlan.h include, not remove it.
