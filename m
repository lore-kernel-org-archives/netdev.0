From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] macvlan: add VLAN filters to lowerdev
Date: Mon, 06 Jun 2011 15:03:52 -0700 (PDT)
Message-ID: <20110606.150352.392614415181146213.davem@davemloft.net>
References: <20110606142715.2692.6311.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: john.r.fastabend@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35874 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753290Ab1FFWD5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 18:03:57 -0400
In-Reply-To: <20110606142715.2692.6311.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>
Date: Mon, 06 Jun 2011 07:27:16 -0700

> Stacking VLANs on top of the macvlan device does not
> work if the lowerdev device is using vlan filters set
> by NETIF_F_HW_VLAN_FILTER. Add ndo ops to pass vlan
> calls to lowerdev.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

I think this might have unintended side-effects.

Much of the VLAN code makes decisions based upon whether these
ops are NULL or not.

Now, no matter what is implemented in the lower device, the VLAN
code will see them non-NULL in the macvlan device.
