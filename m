From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next v1 0/9] bonding: remove vlan special handling
Date: Mon, 26 Aug 2013 22:32:33 +0200
Message-ID: <1377549162-7522-1-git-send-email-vfalico@redhat.com>
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
Received: from mx1.redhat.com ([209.132.183.28]:61496 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752298Ab3HZUce (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Aug 2013 16:32:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v1: Per Jiri's advice, remove the exported netdev_upper struct to keep it
    inside dev.c only, and instead implement a macro to iterate over the
    list and return only net_device *.

The aim of this patchset is to remove bondings' own vlan handling as much
as possible and replace it with the netdev upper device functionality.

This is achieved by adding a helper function to upper dev list handling -
netdev_upper_get_next_dev(dev, iter), which returns the next device after
the list_head **iter, and sets *iter to the next list_head *. This patchset
also adds netdev_for_each_upper_dev(dev, upper, iter), which iterates
through the whole dev->upper_dev_list, setting upper to the net_device.
The only special treatment of vlans remains in rlb code.

This patchset solves several issues with bonding, simplifies it overall,
RCUify further and exports upper list functions for any other users which
might also want to get rid of its own vlan_lists.

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
 drivers/net/bonding/bond_alb.c  |   75 ++++++------
 drivers/net/bonding/bond_alb.h  |    2 -
 drivers/net/bonding/bond_main.c |  244 ++++++++-------------------------------
 drivers/net/bonding/bonding.h   |   21 +++-
 include/linux/netdevice.h       |   10 ++
 net/core/dev.c                  |   25 ++++
 6 files changed, 133 insertions(+), 244 deletions(-)
