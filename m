From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/3] bonding: rcu cleanups
Date: Tue, 15 Jul 2014 02:46:41 -0700
Message-ID: <1405417604-7828-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Mahesh Bandewar <maheshb@google.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f201.google.com ([209.85.223.201]:64401 "EHLO
	mail-ie0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757913AbaGOJqt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 05:46:49 -0400
Received: by mail-ie0-f201.google.com with SMTP id tr6so785725ieb.4
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2014 02:46:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RCU was added to bonding in linux-3.12 but lacked proper sparse annotations.

Using __rcu annotation actually helps to spot all accesses to bond->curr_active_slave
are correctly protected, with full sparse & LOCKDEP support.

Lets clean the code.

Eric Dumazet (3):
  bonding: get rid of bond_option_active_slave_get()
  bonding: use rcu_access_pointer() in bonding_show_mii_status()
  bonding: add proper __rcu annotation for curr_active_slave

 drivers/net/bonding/bond_alb.c     | 47 +++++++++++++++++++--------------
 drivers/net/bonding/bond_main.c    | 53 +++++++++++++++++++++-----------------
 drivers/net/bonding/bond_netlink.c | 21 +++++++++++----
 drivers/net/bonding/bond_options.c |  7 +----
 drivers/net/bonding/bond_sysfs.c   |  3 ++-
 drivers/net/bonding/bonding.h      |  7 +++--
 6 files changed, 81 insertions(+), 57 deletions(-)

-- 
2.0.0.526.g5318336
