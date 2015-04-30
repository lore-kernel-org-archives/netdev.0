From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [PATCH 0/3] A few minor clean-ups to eth_type_trans
Date: Thu, 30 Apr 2015 14:53:42 -0700
Message-ID: <20150430214917.1798.49769.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33955 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750791AbbD3Vxo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Apr 2015 17:53:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series addresses a few minor issues I found in eth_type_trans that
that allow us to gain back something like 3 or more cycles per packet.  

The first change is to drop the byte swap since it isn't necessary.  On x86
we could just check the first byte and compare that against the upper 8
bits of the Ethertype to determine if we are dealing with a size value or
not.

The second makes it so that the value we read in to test for multicast can
be used for the address comparison.  This allows us to avoid a second read
of the destination address.

The final change is to avoid some unneeded instructions in computing the
Ethernet header pointer.  When we start the call the Ethernet header is at
skb->data, so we just use that rather than computing mac_header, and then
adding that back to skb->head.

---

Alexander Duyck (3):
      etherdev: Avoid unnecessary byte swap in check for Ethertype
      etherdev: Process is_multicast_ether_addr at same size as other operations
      etherdev: Use skb->data to retrieve Ethernet header instead of eth_hdr


 include/linux/etherdevice.h |   24 +++++++++++++++++++++++-
 net/ethernet/eth.c          |    7 ++++---
 2 files changed, 27 insertions(+), 4 deletions(-)

--
