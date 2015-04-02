From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/12] Remove iflink field from the
 net_device structure
Date: Thu, 02 Apr 2015 14:05:26 -0400 (EDT)
Message-ID: <20150402.140526.798085948544052697.davem@davemloft.net>
References: <1422979929.907.19.camel@edumazet-glaptop2.roam.corp.google.com>
	<1427987231-3669-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40172 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752415AbbDBSF3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 14:05:29 -0400
In-Reply-To: <1427987231-3669-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Thu,  2 Apr 2015 17:06:59 +0200

> The first goal of this series was to advertise the veth peer via the IFLA_LINK
> attribute, but iflink was not ready for network namespaces.
> 
> The iflink of an interface should be set to its ifindex for a physical interface
> and to another value (0 if not relevant) for a virtual interface.
> This was not the case for some interfaces, like vxlan, bond, or bridge for
> example.
> There is also a risk, if the targeted interface moves to another netns, that the
> ifindex changes without updating corresponding iflink fields (eg. vlan).
> 
> Moving the management of this property into virtual interface drivers allows to
> better handle this last case because most of virtual interface drivers have a
> pointer to the link netdevice.
> Anyway, dev->iflink value was always a copy of some internal data of the virtual
> interface driver, thus let's use these internal data directly.
> 
> So, this series removes the iflink field and let the drivers manage it.
> Only the last patch was present in the v1, but I fully rework it.

I like this a lot, series applied, thanks Nicolas.
