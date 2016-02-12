From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH RFC 0/3] net: bridge: set forwarding state when unbridging switchdev ports
Date: Fri, 12 Feb 2016 16:34:17 -0500
Message-ID: <1455312860-24666-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>,
	Scott Feldman <sfeldma@gmail.com>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Ido Schimmel <idosch@mellanox.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When a port leaves a bridge, the bridge layer sets its STP state to Disabled.

But switchdev users seem to need to restore its state to Forwarding to keep the
communication with the CPU port functional (see DSA and Rocker for instance).

br_set_state() tries to set the switchdev port state, if correctly implemented.
So call it within del_nbp() to restore the Forwarding state on port removal.

Does that make sense or are there scenarios where we don't want this behavior?

Thanks,

Vivien Didelot (3):
  net: bridge: log state when setting it
  net: bridge: set forwarding state on port removal
  net: dsa: remove dsa_slave_stp_update

 net/bridge/br_if.c  |  5 +++++
 net/bridge/br_stp.c |  5 ++---
 net/dsa/slave.c     | 17 -----------------
 3 files changed, 7 insertions(+), 20 deletions(-)

-- 
2.7.1
