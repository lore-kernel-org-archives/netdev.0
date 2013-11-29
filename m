From: Thomas Graf <tgraf@suug.ch>
Subject: [RFC] Should skb->csum include 8021Q header for CHECKSUM_COMPLETE &&
 NETIF_F_HW_VLAN_CTAG_RX
Date: Fri, 29 Nov 2013 13:28:19 +0000
Message-ID: <20131129132819.GA9176@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:50909 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753156Ab3K2N2U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Nov 2013 08:28:20 -0500
Received: from tgr by casper.infradead.org with local (Exim 4.80.1 #2 (Red Hat Linux))
	id 1VmO7H-0005Zk-Kv
	for netdev@vger.kernel.org; Fri, 29 Nov 2013 13:28:19 +0000
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

Given CHECKSUM_COMPLETE, is skb->csum supposed to include the
checksum of the VLAN header if the header was stripped by the
NIC?

The answer is clear for non accelerated VLAN: it covers all of
the packet without ethernet CRC.

For the accelerated path the answer is less clear after staring
at drivers. The stack currently only fixes the csum for the
software path.

We are seeing hw csum failure warnings for drivers like enic if
OVS pops a VLAN header that was previously stripped  in hardware.
Should we force CHECKSUM_NONE like VXLAN does or are all drivers
guaranteed to include VLAN bits for CHECK_COMPLETE regardless of
acceleration?

Best,
Thomas
