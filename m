From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] team: team should sync the port's uc/mc addrs when add a port
Date: Tue, 29 Mar 2016 00:42:31 +0800
Message-ID: <320fc71dbbf5ed164ca506cf5750b7bf4e048d44.1459183351.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, Jiri Pirko <jiri@resnulli.us>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35712 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755146AbcC1Qmi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2016 12:42:38 -0400
Received: by mail-pf0-f195.google.com with SMTP id u190so21740476pfb.2
        for <netdev@vger.kernel.org>; Mon, 28 Mar 2016 09:42:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is an issue when we use mavtap over team:
When we replug nic links from team0, the real nics's mc list will not
include the maddr for macvtap any more. then we can't receive pkts to
macvtap device, as they are filterred by mc list of nic.

In Bonding Driver, it syncs the uc/mc addrs in bond_enslave().

We will fix this issue on team by adding the port's uc/mc addrs sync in
team_port_add.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 drivers/net/team/team.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 26c64d2..17ff367 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1198,6 +1198,9 @@ static int team_port_add(struct team *team, struct net_device *port_dev)
 		goto err_dev_open;
 	}
 
+	dev_uc_sync_multiple(port_dev, dev);
+	dev_mc_sync_multiple(port_dev, dev);
+
 	err = vlan_vids_add_by_dev(port_dev, dev);
 	if (err) {
 		netdev_err(dev, "Failed to add vlan ids to device %s\n",
-- 
2.1.0
