From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH v4 0/3] Correctly perform offloads when VNET_HDR is disabled
Date: Fri, 16 Aug 2013 15:24:59 -0400
Message-ID: <1376681102-19753-1-git-send-email-vyasevic@redhat.com>
Cc: mst@redhat.com, Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56782 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754138Ab3HPWyL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Aug 2013 18:54:11 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r7GJP6cQ015014
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 16 Aug 2013 15:25:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes since v3:
 - The main change here is that instead of mucking around with checksum bits,
   we instead treat macvtap as macvlan+tap each with separate feature sets.
   tap_features identify the features of only the 'tap' part and we only use
   them when forwarding, essentially making the 'tap' part a pseudo-device.
   To properly handle GSO, we always set NETIF_F_SG | NETIF_F_GSO on the
   'tap' part.

 - The rest of the set is mostly the same in that we allow user to change
   tap offload features whether VNET_HDR is set or cleared.  
 - When VNET_HDR is disabled, we ignore user specified tap offloads.  This
   is now a separate patch so that if there are disagreements, it can
   be easily dropped.

Vlad Yasevich (3):
  macvtap: simplify usage of tap_features
  macvtap: Correctly set tap features when IFF_VNET_HDR is disabled.
  macvtap: Ignore tap features when VNET_HDR is off

 drivers/net/macvtap.c | 33 ++++++++++++++++++++++++---------
 1 file changed, 24 insertions(+), 9 deletions(-)

-- 
1.8.1.4
