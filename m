From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bonding: fix vlan_features computing
Date: Wed, 07 May 2014 14:08:46 -0400 (EDT)
Message-ID: <20140507.140846.1449010184057650775.davem@davemloft.net>
References: <20140505.234500.89241173582893591.davem@davemloft.net>
	<17712.1399362807@localhost.localdomain>
	<20140506130315.GB18366@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jay.vosburgh@canonical.com, netdev@vger.kernel.org,
	vfalico@gmail.com, andy@greyhouse.net, mirq-linux@rere.qmqm.pl
To: mkubecek@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50600 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752344AbaEGSIs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 14:08:48 -0400
In-Reply-To: <20140506130315.GB18366@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kubecek <mkubecek@suse.cz>
Date: Tue, 6 May 2014 15:03:15 +0200

> On Tue, May 06, 2014 at 12:53:27AM -0700, Jay Vosburgh wrote:
>> 
>> 	The VLAN device doesn't get _HW_CSUM (aka _GEN_CSUM)?  In
>> ethtool, this is tx-checksum-ip-generic, I believe.
>> 
>> 	I have only one machine with a _IP_CSUM only device (a tg3) set
>> up at the moment, it's running a Fedora 20 3.13 kernel, and a vlan ->
>> bond0 -> eth0 stack shows "generic" offload for the vlan and bond0, and
>> "ipv4" offload for the eth0 itself.
> 
> I checked now and at least since 3.12 bond has NETIF_F_HW_CSUM in its
> features even if its slaves have only NETIF_F_IP(V6)_CSUM. Therefore
> NETIF_F_HW_CSUM in vlan_features does no harm and vlan on top of the
> bond gets NETIF_F_HW_CSUM.
> 
> Unfortunately it means that while I still think the change I proposed
> is correct, it would break things unless computing features of the bond
> is fixed in similar way or vlan_dev_fix_features is modified to handle
> checksumming features more carefully.

I think we need to think more about what exact behavior is desired in
mixed csum feature set cases.  Probably whatever csum offload type is
the most prevelant should be the one advertised by the master.  It
means we will do that software checksum fixup for the oddball slaves,
but it seems the best we can do.

Also, like Jay, I agree that whatever we do in bonding needs to be
done in team too and I'd like the bug fixed at the same time in both
places.

Therefore I'm marking this patch as "changes requested", thanks.
