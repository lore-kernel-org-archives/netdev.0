From: Antonio Quartulli <antonio@open-mesh.com>
Subject: [PATCH 0/3] bridge: implement restricted forwarding policy
Date: Mon, 8 Apr 2013 19:41:00 +0200
Message-ID: <1365442863-32394-1-git-send-email-antonio@open-mesh.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <bridge@lists.linux-foundation.org>, <netdev@vger.kernel.org>,
	Antonio Quartulli <antonio@open-mesh.com>
To: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ht1.myhostedexchange.com ([69.50.2.37]:59732 "EHLO
	ht1.hostedexchange.local" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1763332Ab3DHRsC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 13:48:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

with this patchset I would like to introduce a new feature to be added to the
bridge module that is later going to be one of the building block of a
distributed technique implemented using batman-adv.

The scenario where we want to play is a Layer2 mesh network handled by
the batman-adv module. For who may not know how it works, batman-adv creates a
sort of "extended broadcast domain" shared among nodes that are not directly
connected to each other.
This mechanism provides every node the view of the batman-adv network
as it was a very big Ethernet switch.


The goal we want to achieve by adding this feature consists in selecting a
subset of the interfaces available on all the hosts participating to the mesh
network and to prevent packets from being forwarded from one of them to another.

Looking again at the "very big switch" abstraction this would allow a mesh
network administrator to define a sort of "not forwarding policy network wide"
between some of the big switch's port.

This patchset is introducing the small piece needed by every hosts in the
network to handle the policy locally. In particular, I'm adding a new flag for
the net_device->flags member (IFF_BRIDGE_RESTRICTED) and a new attribute to the
sk_buff structure (bridge_restricted), then the bridge code is modified to
obey the following rule:

* do not forward any skb with the bridge_restricted attribute set to interfaces
  marked with the IFF_BRIDGE_RESTRICTED flag.


Later, a change to batman-adv will follow which will make it spit out skbs with
the bridge_restricted member set depending on its distributed logic.


I am not entirely sure if I chose the very best place for those flags. If not,
please advise :)

Thanks a lot.


Cheers,


Antonio Quartulli (3):
  if.h: add IFF_BRIDGE_RESTRICTED flag
  sk_buff: add bridge_restricted flag
  bridge: implement restricted port forwarding policy

 include/linux/skbuff.h  |  3 ++-
 include/uapi/linux/if.h |  1 +
 net/bridge/br_forward.c | 18 +++++++++++++++++-
 net/bridge/br_input.c   |  6 ++++++
 net/core/dev.c          |  2 +-
 5 files changed, 27 insertions(+), 3 deletions(-)

-- 
1.8.1.5
