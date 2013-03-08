From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [RFC net-next 00/11] firewire net: resource management improvements
Date: Fri, 08 Mar 2013 10:40:42 +0900
Message-ID: <5139419A.2040309@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: stefanr@s5r6.in-berlin.de, linux1394-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:39145 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752249Ab3CHBko (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 20:40:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

This series of patches tries to improve resource management of IP over Firewire
device.

Because upcoming IPv6 over Firewire patch depends on this series, it would
be better to let this series of patches go through Dave's net-next tree, if
firewire people do not mind.

--yoshfuji

YOSHIFUJI Hideaki (11):
  firewire net: No need to reset dev->local_fifo after failure of
    fw_core_add_address_handler().
  firewire net: Introduce fwnet_fifo_{start,stop}() helpers.
  firewire net: Setup broadcast and local fifo independently.
  firewire net: Check dev->broadcast_state inside
    fwnet_broadcast_start().
  firewire net: Fix memory leakage in fwnet_remove().
  firewire net: Clear dev->broadcast_rcv_context and
    dev->broadcast_state after destruction of context.
  firewire net: Omit checking dev->broadcast_rcv_context in
    fwnet_broadcast_start().
  firewire net: Fix leakage of kmap for broadcast receive buffer.
  firewire net: Allocate dev->broadcast_rcv_buffer_ptrs early.
  firewire net: Introduce fwnet_broadcast_stop() to destroy broadcast
    resources.
  firewire net: Release broadcast/fifo resources on ifdown.

 drivers/firewire/net.c |  177 ++++++++++++++++++++++++++++--------------------
 1 file changed, 105 insertions(+), 72 deletions(-)

-- 
1.7.9.5
