From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 0/3] qlge: Allow running MSIx with fewer vectors.
Date: Thu, 27 Aug 2009 14:02:08 -0700
Message-ID: <1251406931-15107-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:40659 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752757AbZH0VHv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2009 17:07:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Dave and All,

The purpose of this patch series is to allow MSIx usage on
platforms where vector availability is limited.  The change is to
move broadcast/multicast/firmware event processing from a dedicated
'default' ring into the first RSS ring, and move TX completion
processing into NAPI context.

These patches change the rx_ring to MSIx vector mapping as follows:

FROM-
- 1 x default rx_ring (broadcast/multicast/firmware events)
- cpu_count x RSS rx_rings
- cpu_count x TX completion rx_rings.

We then attempt to allocate a vector for each rx_ring.  If it fails then
we drop down to MSI/Legacy single interrupt.  This is not efficient.


TO-
1) Get rid of dedicated default rx_ring and add it's extra functionality
	to the first RSS ring.
2) Allocate one RSS ring for each MSIX vector.
3) Allocate one TX completion ring for each CPU.
4) Move TX completion ring processing to NAPI context.

Each interrupt will start NAPI to process it's RSS ring and
and one or more TX completion rx_rings.

Regards,
Ron Mercer


