From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: [PATCH v2 0/5] ipvlan: fix ipv6 autoconfiguration
Date: Fri, 03 Jul 2015 15:58:35 +0300
Message-ID: <20150703125132.24121.50592.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Mahesh Bandewar <maheshb@google.com>, Jiri Benc <jbenc@redhat.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward-corp1g.mail.yandex.net ([95.108.253.251]:59510 "EHLO
	forward-corp1g.mail.yandex.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755120AbbGCM6j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2015 08:58:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset fixes ipvlan and its interaction with ipv6 RA. Now ipvlan l2
ports get dev_id and construct unique ipv6 addresses using one mac address.

Changes since v1 (http://comments.gmane.org/gmane.linux.network/363346)
* locking for ipv6 addresses fixed inside ipvlan
* rcu splat will be fixed with this: https://patchwork.ozlabs.org/patch/471481/
* new fix for trivial memory leak and patch which removes address counters

---

Konstantin Khlebnikov (5):
      ipvlan: remove counters of ipv4 and ipv6 addresses
      ipvlan: plug memory leak in ipvlan_link_delete
      ipvlan: unhash addresses without synchronize_rcu
      ipvlan: protect addresses with internal spinlock
      ipvlan: set dev_id for l2 ports to generate unique IPv6 addresses


 Documentation/networking/ipvlan.txt |   11 +++
 drivers/net/ipvlan/ipvlan.h         |   16 ++++-
 drivers/net/ipvlan/ipvlan_core.c    |    6 --
 drivers/net/ipvlan/ipvlan_main.c    |  118 +++++++++++++++++++++++------------
 4 files changed, 100 insertions(+), 51 deletions(-)

--
Konstantin
