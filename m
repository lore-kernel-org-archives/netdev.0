From: Chris Leech <christopher.leech@intel.com>
Subject: Question about supporting non-IP offloads (FCoE)
Date: Wed, 24 Sep 2008 13:55:26 -0700
Message-ID: <48DAA93E.5010102@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:59246 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752254AbYIXUz1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2008 16:55:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm looking at adding support for stateless offloads to the Fibre
Channel over Ethernet stack at open-fcoe.org that roughly match
currently supported TCP offloads:  Fibre Channel CRC offload on Tx and
Rx, and sequencing offload (GSO) on Tx.

>From the net_device all I see the need for is two feature flags bits for
the transmit path, one for FC-CRC and one for FCoE GSO.

In the skb, the FCoE needs match up well with the existing CRC and GSO
fields.  I would like to reuse the ip_summed bits rather than add to the
skb, but I suspect this will be the most controversial part of the FCoE
offloads.

Are there any objections to the idea of adding checks for FCoE protocol
to the dev_queue_xmit/dev_can_checksum/can_checksum_protocol path?
Obviously skb_checksum_help isn't going to work as a software fallback
and a protocol check would need to be added there as well, or a
per-protocol helper like is done for gso_segment.

- Chris
