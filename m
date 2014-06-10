From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Subject: [PATCH v2 net-next 0/2] some mac802154 fixes
Date: Tue, 10 Jun 2014 18:11:09 +0200
Message-ID: <1402416671-30305-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Cc: linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:50701 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752245AbaFJQLg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2014 12:11:36 -0400
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.4/8.14.4/Debian-7) with ESMTP id s5AGBSUj021119
	(version=TLSv1/SSLv3 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 10 Jun 2014 18:11:30 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recent llsec code introduced a memory leak on decryption failures during rx.
This fixes said leak, and optimizes the receive loops for monitor and wpan
devices to only deliver skbs to devices that are actually up.

---


Phoebe Buckheister (2):
      mac802154: properly free incoming skbs on decryption failure
      mac802154: don't deliver packets to devices that are down

 net/mac802154/monitor.c |    3 ++-
 net/mac802154/rx.c      |    9 ++++++---
 net/mac802154/wpan.c    |   14 +++++++++-----
 3 files changed, 17 insertions(+), 9 deletions(-)
