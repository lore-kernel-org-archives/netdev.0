From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next 0/3] bonding: struct bonding cleanup and MAC set fixes
Date: Wed, 26 Jun 2013 17:13:36 +0200
Message-ID: <1372259619-32430-1-git-send-email-nikolay@redhat.com>
Cc: davem@davemloft.net, andy@greyhouse.net, fubar@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11996 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752065Ab3FZPRS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jun 2013 11:17:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
This patchset removes some unnecessary struct bonding members. It also
fixes MAC setting inconsistencies (i.e. if a bond's MAC is set after
creation but prior to enslaving, it is lost and the first slave's MAC is
cloned again). Before these patches the only way to keep a user-defined MAC
is either to set it after enslaving or to create the bond with that MAC.
Patch 01 - removes setup_by_slave member
Patch 02 - removes dev_addr_from_first member and does the MAC fixing
Patch 03 - introduces the use of NET_ADDR_STOLEN when a MAC is cloned

Best regards,
 Nikolay Aleksandrov

Nikolay Aleksandrov (3):
  bonding: remove unnecessary setup_by_slave member
  bonding: remove unnecessary dev_addr_from_first member
  bonding: when cloning a MAC use NET_ADDR_STOLEN

 drivers/net/bonding/bond_main.c | 45 ++++++++++++++++++++---------------------
 drivers/net/bonding/bonding.h   |  2 --
 2 files changed, 22 insertions(+), 25 deletions(-)

-- 
1.8.1.4
