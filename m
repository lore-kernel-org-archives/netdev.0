From: David Miller <davem@davemloft.net>
Subject: Re: ibmveth: Fix endian issues with MAC addresses
Date: Thu, 06 Mar 2014 16:27:37 -0500 (EST)
Message-ID: <20140306.162737.1605594893806967606.davem@davemloft.net>
References: <1387810329.22671.66.camel@joe-AO722>
	<20131224125529.58970f1b@kryten>
	<20140305145137.3460dbe7@kryten>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, agraf@suse.de, benh@kernel.crashing.org,
	dvaleev@suse.com, santil@linux.vnet.ibm.com,
	tony@bakeyournoodle.com, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org
To: anton@samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33581 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752671AbaCFV1k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 16:27:40 -0500
In-Reply-To: <20140305145137.3460dbe7@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Blanchard <anton@samba.org>
Date: Wed, 5 Mar 2014 14:51:37 +1100

> The code to load a MAC address into a u64 for passing to the
> hypervisor via a register is broken on little endian.
> 
> Create a helper function called ibmveth_encode_mac_addr
> which does the right thing in both big and little endian.
> 
> We were storing the MAC address in a long in struct ibmveth_adapter.
> It's never used so remove it - we don't need another place in the
> driver where we create endian issues with MAC addresses.
> 
> Signed-off-by: Anton Blanchard <anton@samba.org>
> Cc: stable@vger.kernel.org

Applied, thanks Anton.

> -	memcpy(&adapter->mac_addr, mac_addr_p, ETH_ALEN);
 ...
> -    unsigned long mac_addr;

That's some scary stuff right there.
