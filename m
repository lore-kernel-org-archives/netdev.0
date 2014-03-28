From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net 0/4] Audit all drivers for correct vlan_features.
Date: Thu, 27 Mar 2014 22:14:45 -0400
Message-ID: <1395972889-32289-1-git-send-email-vyasevic@redhat.com>
Cc: Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12502 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757010AbaC1COw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2014 22:14:52 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s2S2EpOE004174
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 22:14:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some drivers set vlan acceleration features in vlan_features.  This causes
issues with Q-in-Q/802.1ad configurations.

Audit all the drivers for correct vlan_features.  Fix broken ones.
Add a warning to vlan code to help catch future offenders.

Vlad Yasevich (4):
  qlge: Do not propaged vlan tag offloads to vlans
  ifb: Remove vlan acceleration from vlan_features
  veth: Turn off vlan rx acceleration in vlan_features
  vlan: Mask off vlan acceleration features on vlan device.

 drivers/net/ethernet/qlogic/qlge/qlge_main.c | 4 +++-
 drivers/net/ifb.c                            | 3 ++-
 drivers/net/veth.c                           | 5 ++++-
 include/linux/netdev_features.h              | 5 +++++
 net/8021q/vlan_dev.c                         | 4 ++++
 5 files changed, 18 insertions(+), 3 deletions(-)

-- 
1.8.5.3
