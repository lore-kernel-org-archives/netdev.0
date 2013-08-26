From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 0/8] bonding: remove vlan special handling
Date: Mon, 26 Aug 2013 18:28:45 +0200
Message-ID: <1377534533-6944-1-git-send-email-vfalico@redhat.com>
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Cong Wang <amwang@redhat.com>,
	Veaceslav Falico <vfalico@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4048 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757183Ab3HZQ2z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Aug 2013 12:28:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The aim of this patchset is to remove bondings' own vlan handling as much
as possible and replace it with the netdev upper device functionality.

This is achieved by exporting the netdev_upper structure and thus permiting
bonding to work directly with its upper devices. The only non-bonding
change is the exporting of netdev_upper, and the only special treatment of
vlans left is in the rlb mode.

This patchset solves several issues with bonding, simplifies it overall,
RCUify further and exports netdev_upper for any other users which might
also want to get rid of its own vlan_lists.

I'm testing it continuously currently, no issues found, will update on
anything.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: "David S. Miller" <davem@davemloft.net>
CC: Eric Dumazet <edumazet@google.com>
CC: Jiri Pirko <jiri@resnulli.us>
CC: Alexander Duyck <alexander.h.duyck@intel.com>
CC: Cong Wang <amwang@redhat.com>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

---
 drivers/net/bonding/bond_alb.c  |   74 ++++++------
 drivers/net/bonding/bond_alb.h  |    2 -
 drivers/net/bonding/bond_main.c |  243 ++++++++-------------------------------
 drivers/net/bonding/bonding.h   |   20 ++-
 include/linux/netdevice.h       |    8 ++
 net/core/dev.c                  |    8 --
 6 files changed, 103 insertions(+), 252 deletions(-)
