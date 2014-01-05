From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V1 0/2] Add UDP GRO support for vxlan traffic
Date: Sun,  5 Jan 2014 17:23:40 +0200
Message-ID: <1388935422-7331-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net, yanb@mellanox.com,
	shlomop@mellanox.com, Or Gerlitz <ogerlitz@mellanox.com>
To: hkchu@google.com, edumazet@google.com, herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:49958 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751208AbaAEPXw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Jan 2014 10:23:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add GRO handlers for UDP, with the intent of being able to coalesce vxlan
packets which encapsulate packets belonging to the same TCP session.

The UDP GRO handler will only attempt to coalesce packets whose
destination port is used as vxlan listening port.

Patches are against net-next a1d4b03a076d95e "Merge branch 'bgmac'" plus 
Jerry's gro-gre patch which adds the gro_find_receive/complete_by_type helpers

Or.

changes from V0:
 - addressed feedback from Dave on the pre-patch
 - added helpers used by the vxlan code to notify the udp gro code 
   which ports are used for vxlan

Or Gerlitz (2):
  net: Pre-step for supporting GRO on vxlan traffic
  net: Add UDP GRO support for vxlan traffic

 drivers/net/vxlan.c    |   13 ++---
 include/net/protocol.h |    3 +
 include/net/vxlan.h    |    6 ++
 net/ipv4/udp_offload.c |  127 ++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 141 insertions(+), 8 deletions(-)
