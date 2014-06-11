From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Subject: some mac802154 fixes
Date: Wed, 11 Jun 2014 12:03:05 +0200
Message-ID: <1402480987-492-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Cc: linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:55853 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751070AbaFKKDb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 06:03:31 -0400
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.4/8.14.4/Debian-7) with ESMTP id s5BA3T49005632
	(version=TLSv1/SSLv3 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 11 Jun 2014 12:03:29 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recent llsec code introduced a memory leak on decryption failures during rx.
This fixes said leak, and optimizes the receive loops for monitor and wpan
devices to only deliver skbs to devices that are actually up. Also changes a
dev_kfree_skb to kfree_skb when an invalid packet is dropped before being
pushed into the stack.

---

Phoebe Buckheister (2):
      mac802154: properly free incoming skbs on decryption failure
      mac802154: don't deliver packets to devices that are down

 net/mac802154/monitor.c |    3 ++-
 net/mac802154/rx.c      |   11 +++++++----
 net/mac802154/wpan.c    |   14 +++++++++-----
 3 files changed, 18 insertions(+), 10 deletions(-)
