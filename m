From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] fix bonding neighbour setup handling
Date: Fri, 02 Aug 2013 15:45:39 -0700 (PDT)
Message-ID: <20130802.154539.237539535236462726.davem@davemloft.net>
References: <1375463259-12033-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	ebiederm@xmission.com, joe@perches.com
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42691 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752353Ab3HBWpl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 18:45:41 -0400
In-Reply-To: <1375463259-12033-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Fri,  2 Aug 2013 19:07:37 +0200

> Recent patches revealed an old bug, which was there for quite awhile. It's
> related to vlan on top of bonding and ndo_neigh_setup(). When vlan device
> is initiated, it calls its real_dev->ndo_neigh_setup(), and in case of
> bonding - it will modify neigh_parms->neigh_setup to point to
> bond_neigh_init, while neigh_parms are of vlan's dev.
> 
> This way, when neigh_parms->neigh_setup() of vlan's dev is called, the
> bonding function will be called, which expects the dev to be struct
> bonding, but will receive a vlan dev.
> 
> It was hidden before because of bond->first_slave usage. Now, with
> Nikolay's conversion to list/RCU, first_slave is gone and we hit a null
> pointer dereference when working with lists/slave.
> 
> First patch moves ndo_neigh_setup() in neigh_parms_alloc() to the bottom,
> so that the ->dev will be available to the caller. It doesn't really change
> anything, however is needed for the second patch.
> 
> Second patch makes bond_neigh_setup() (bond->ndo_neigh_setup()) check if
> the neigh_parms are really from a bonding dev, and only modify the
> neigh_setup in this case.

Thanks for the detailed explanation of the situation, it made your patches
trivial to review.

Applied, thanks.
