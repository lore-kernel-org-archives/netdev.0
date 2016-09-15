From: John Crispin <john@phrozen.org>
Subject: MDB offloading of local ipv4 multicast groups
Date: Thu, 15 Sep 2016 20:58:50 +0200
Message-ID: <ebb1092f-4fab-c490-0553-b108feb5e8d4@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Ido Schimmel <idosch@mellanox.com>, Jiri Pirko <jiri@mellanox.com>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        "David S. Miller" <davem@davemloft.net>
To: Elad Raz <eladr@mellanox.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:56719 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753777AbcIOS64 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Sep 2016 14:58:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

While adding MDB support to the qca8k dsa driver I found that ipv4 mcast
groups don't always get propagated to the dsa driver. In my setup there
are 2 clients connected to the switch, both running a mdns client. The
.port_mdb_add() callback is properly called for 33:33:00:00:00:FB but
01:00:5E:00:00:FB never got propagated to the dsa driver.

The reason is that the call to ipv4_is_local_multicast() here [1] will
return true and the notifier is never called. Is this intentional or is
there something missing in the code ?

	John

[1]
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/net/bridge/br_multicast.c?id=refs/tags/v4.8-rc6#n737
