From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC PATCH net-next 0/2] net: switchdev: add attribute for port bridging
Date: Wed,  9 Mar 2016 12:42:46 -0500
Message-ID: <1457545368-20647-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Ido Schimmel <idosch@mellanox.com>,
	nikolay@cumulusnetworks.com, Elad Raz <eladr@mellanox.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:58624 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751912AbcCIRnI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 12:43:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current switchdev users implement notifier blocks to filter global netdev
events, in order to correctly offload bridging to their hardware ports.

Such code could be replaced with the support of a simple switchdev attribute
set when adding/deleting a port to/from a bridge.

Also, we can imagine a switch driver or network layer wanting to restrict the
number of logical bridges on top of a physical device. That could be done by
returning -EOPNOTSUPP when setting such attribute.

The first patch adds a new SWITCHDEV_ATTR_ID_PORT_BRIDGE_IF switchdev attribute
containing a boolean, set when joining or leaving a bridge.

The second patch shows the benefit of supporting such attribute in the DSA
layer. Similar change should be doable to other switchdev users, like Rocker.

Note: I send this as an RFC since I am not really sure about the attribute
flags, and the exact place to set it in del_nbp(). Comments needed :-)

Thanks,

Vivien Didelot (2):
  net: bridge: add switchdev attr for port bridging
  net: dsa: support SWITCHDEV_ATTR_ID_PORT_BRIDGE_IF

 include/net/switchdev.h |   2 +
 net/bridge/br_if.c      |  27 ++++++++++++
 net/dsa/dsa.c           |   7 ---
 net/dsa/dsa_priv.h      |   2 -
 net/dsa/slave.c         | 113 +++++++++++++-----------------------------------
 5 files changed, 59 insertions(+), 92 deletions(-)

-- 
2.7.2
