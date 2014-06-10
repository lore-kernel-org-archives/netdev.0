From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Subject: [PATCH net-next] some mac802154 fixes
Date: Tue, 10 Jun 2014 17:08:40 +0200
Message-ID: <1402412922-14180-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Cc: linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:43639 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752021AbaFJPJH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2014 11:09:07 -0400
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.4/8.14.4/Debian-7) with ESMTP id s5AF90Cv026395
	(version=TLSv1/SSLv3 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 10 Jun 2014 17:09:00 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recent llsec code introduced a memory leak on decryption failures during rx.
This fixes said leak, and optimizes the receive loop to only deliver skbs to
the (single) device that's actually up.

---

Phoebe Buckheister (2):
      mac802154: properly free incoming skbs on decryption failure
      mac802154: don't deliver packets to devices that are down


 net/mac802154/wpan.c |   13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)
