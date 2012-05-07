From: Julien Ducourthial <jducourt@free.fr>
Subject: r8169: problem with TSO (TX_BUFFS_AVAIL negative value)
Date: Tue, 08 May 2012 00:35:44 +0200
Message-ID: <1336430144.11363.35.camel@blackbone.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel@vger.kernel.org
To: nic_swsd@realtek.com, romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1-g21.free.fr ([212.27.42.1]:51111 "EHLO smtp1-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753340Ab2EGWfx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2012 18:35:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Whenever I activate TSO on my realtek based NIC, it gets stuck after a
while under heavy traffic (both under an zotac amd board with a 8111e on
board and an intel D510MO atom with 8111d on board).

After doing some investigation (with systemtap), the problem seems to be
that the net_device is not stopped when all TX descriptors are in use.

This behavior comes from the macro TX_BUFFS_AVAIL(tp). It is an unsigned
expression but returns -1 when the transmit queue is full (the macro
handles the room for the skb and the frags). 

This condition only happens when you have skb with lots of frags
(otherwise the nic is stopped before all TX desc are in use), hence only
in the tso case for me.

I made a small patch to avoid negative values, and the driver works
great with TSO. With my atom based board I can now reach maximum
throughput as an NFS server.

Best regards,

Julien Ducourthial (1):
  r8169: fix problem with TSO (TX_BUFFS_AVAIL negative value)

 drivers/net/ethernet/realtek/r8169.c |   16 ++++++++++------
 1 files changed, 10 insertions(+), 6 deletions(-)

-- 
1.7.7.6
