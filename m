From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH net] bonding: fix vlan_features computing
Date: Tue, 6 May 2014 15:03:15 +0200
Message-ID: <20140506130315.GB18366@unicorn.suse.cz>
References: <20140502165448.D8078E635B@unicorn.suse.cz>
 <20140505.234500.89241173582893591.davem@davemloft.net>
 <17712.1399362807@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	vfalico@gmail.com, andy@greyhouse.net, mirq-linux@rere.qmqm.pl
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:37041 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753438AbaEFNDR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2014 09:03:17 -0400
Content-Disposition: inline
In-Reply-To: <17712.1399362807@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 06, 2014 at 12:53:27AM -0700, Jay Vosburgh wrote:
> 
> 	The VLAN device doesn't get _HW_CSUM (aka _GEN_CSUM)?  In
> ethtool, this is tx-checksum-ip-generic, I believe.
> 
> 	I have only one machine with a _IP_CSUM only device (a tg3) set
> up at the moment, it's running a Fedora 20 3.13 kernel, and a vlan ->
> bond0 -> eth0 stack shows "generic" offload for the vlan and bond0, and
> "ipv4" offload for the eth0 itself.

I checked now and at least since 3.12 bond has NETIF_F_HW_CSUM in its
features even if its slaves have only NETIF_F_IP(V6)_CSUM. Therefore
NETIF_F_HW_CSUM in vlan_features does no harm and vlan on top of the
bond gets NETIF_F_HW_CSUM.

Unfortunately it means that while I still think the change I proposed
is correct, it would break things unless computing features of the bond
is fixed in similar way or vlan_dev_fix_features is modified to handle
checksumming features more carefully.

                                                        Michal Kubecek
