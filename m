From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 4/17 net-2.6.26] [NETNS]: Disable inetaddr notifiers in namespaces other than initial.
Date: Tue, 19 Feb 2008 10:31:24 +0300
Message-ID: <1203406297-32725-4-git-send-email-den@openvz.org>
References: <1203406116.27296.1.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, containers@lists.osdl.org,
	devel@openvz.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:60491 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754885AbYBSHbP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Feb 2008 02:31:15 -0500
In-Reply-To: <1203406116.27296.1.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip_fib_init is kept enabled. It is already namespace-aware.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 drivers/net/bonding/bond_main.c |    3 +++
 drivers/net/via-velocity.c      |    3 +++
 drivers/s390/net/qeth_main.c    |    3 +++
 net/sctp/protocol.c             |    3 +++
 4 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 0942d82..9666434 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3511,6 +3511,9 @@ static int bond_inetaddr_event(struct notifier_block *this, unsigned long event,
 	struct bonding *bond, *bond_next;
 	struct vlan_entry *vlan, *vlan_next;
 
+	if (ifa->ifa_dev->dev->nd_net != &init_net)
+		return NOTIFY_DONE;
+
 	list_for_each_entry_safe(bond, bond_next, &bond_dev_list, bond_list) {
 		if (bond->dev == event_dev) {
 			switch (event) {
diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index c50fdee..1525e8a 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -3464,6 +3464,9 @@ static int velocity_netdev_event(struct notifier_block *nb, unsigned long notifi
 	struct velocity_info *vptr;
 	unsigned long flags;
 
+	if (dev->nd_net != &init_net)
+		return NOTIFY_DONE;
+
 	spin_lock_irqsave(&velocity_dev_list_lock, flags);
 	list_for_each_entry(vptr, &velocity_dev_list, list) {
 		if (vptr->dev == dev) {
diff --git a/drivers/s390/net/qeth_main.c b/drivers/s390/net/qeth_main.c
index 62606ce..d063e9e 100644
--- a/drivers/s390/net/qeth_main.c
+++ b/drivers/s390/net/qeth_main.c
@@ -8622,6 +8622,9 @@ qeth_ip_event(struct notifier_block *this,
 	struct qeth_ipaddr *addr;
 	struct qeth_card *card;
 
+	if (dev->nd_net != &init_net)
+		return NOTIFY_DONE;
+
 	QETH_DBF_TEXT(trace,3,"ipevent");
 	card = qeth_get_card_from_dev(dev);
 	if (!card)
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 22a1657..4475f7e 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -629,6 +629,9 @@ static int sctp_inetaddr_event(struct notifier_block *this, unsigned long ev,
 	struct sctp_sockaddr_entry *addr = NULL;
 	struct sctp_sockaddr_entry *temp;
 
+	if (ifa->ifa_dev->dev->nd_net != &init_net)
+		return NOTIFY_DONE;
+
 	switch (ev) {
 	case NETDEV_UP:
 		addr = kmalloc(sizeof(struct sctp_sockaddr_entry), GFP_ATOMIC);
-- 
1.5.3.rc5

