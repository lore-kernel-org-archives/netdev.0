From: "Florian Fainelli" <f.fainelli@gmail.com>
Subject: [PATCH 0/3] net: propagate dynamic needed_headroom/tailroom
 changes
Date: Tue, 20 Aug 2013 13:45:49 +0100
Message-ID: <1377002752-4622-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, jiri@resnulli.us, stephen@networkplumber.org,
	kaber@trash.net, davem@davemloft.net, vyasevic@redhat.com,
	johannes@sipsolutions.net, eric.dumazet@gmail.com,
	"Florian Fainelli" <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4027 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751284Ab3HTMqN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Aug 2013 08:46:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patchset aims at allowing dynamically changing a given device
needed_headroom/tailroom space and propagating such events to stacked
devices such as bridges and vlans.

Unless callers use the new helpers (dev_set_headroom/dev_set_tailroom)
there is no functional change introduced.

I tested this with an out of tree Ethernet driver with both VLANs and
bridges and the need for a 64-byte headroom to insert a transmit
status descriptor in front of a SKB.

Since I am not familiar with all subsystems/drivers changing the
needed_headroom/tailroom requirements, I would leave that to them.

Florian Fainelli (3):
  net: add a new NETDEV_CHANGEROOM event type
  net: vlan: handle NETDEV_CHANGEROOM events
  net: bridge: handle NETDEV_CHANGEROOM event

 include/linux/netdevice.h |  3 +++
 net/8021q/vlan.c          |  7 +++++++
 net/bridge/br_if.c        | 32 ++++++++++++++++++++++++++++++++
 net/bridge/br_notify.c    |  5 +++++
 net/bridge/br_private.h   |  2 ++
 net/core/dev.c            | 46 ++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 95 insertions(+)

-- 
1.8.1.2
