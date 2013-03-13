From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: [git pull] firewire net: resource management improvements
Date: Wed, 13 Mar 2013 16:37:42 +0100
Message-ID: <20130313163742.73a3a842@stein>
References: <5139419A.2040309@linux-ipv6.org>
	<20130313151919.68068bae@stein>
	<20130313.102448.1103259275832948992.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, linux1394-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:50049 "EHLO
	einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932391Ab3CMPh7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 11:37:59 -0400
In-Reply-To: <20130313.102448.1103259275832948992.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

please pull from the tag "firewire-net-resource-mgt" at

    git://git.kernel.org/pub/scm/linux/kernel/git/ieee1394/linux1394.git firewire-net-resource-mgt

to receive the following firewire-net driver changes:
  - fix memory leak and kmap leak at shutdown
  - release IR DMA context already at ifdown rather than shutdown
    (many controllers have got only 4 of them, so let's not hold it
    longer than strictly necessary)
  - misc startup/shutdown changes which prepare for later addition
    of IPv6-over-1394 support

YOSHIFUJI Hideaki (11):
      firewire net: No need to reset dev->local_fifo after failure of fw_core_add_address_handler().
      firewire net: Introduce fwnet_fifo_{start, stop}() helpers.
      firewire net: Setup broadcast and local fifo independently.
      firewire net: Check dev->broadcast_state inside fwnet_broadcast_start().
      firewire net: Fix memory leakage in fwnet_remove().
      firewire net: Clear dev->broadcast_rcv_context and dev->broadcast_state after destruction of context.
      firewire net: Omit checking dev->broadcast_rcv_context in fwnet_broadcast_start().
      firewire net: Fix leakage of kmap for broadcast receive buffer.
      firewire net: Allocate dev->broadcast_rcv_buffer_ptrs early.
      firewire net: Introduce fwnet_broadcast_stop() to destroy broadcast resources.
      firewire net: Release broadcast/fifo resources on ifdown.

 drivers/firewire/net.c | 177 +++++++++++++++++++--------------
 1 file changed, 105 insertions(+), 72 deletions(-)

Thanks,
-- 
Stefan Richter
-=====-===-= --== -==-=
http://arcgraph.de/sr/
