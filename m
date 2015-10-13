From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 0/6] net: dsa: implement port_fdb_dump in drivers
Date: Tue, 13 Oct 2015 11:42:57 -0400
Message-ID: <1444750983-14726-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:55707 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752702AbbJMPn0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 11:43:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not all switch chips provide a Get Next kind of operation to dump FDB entries.
It is preferred to let the driver handle the dump operation the way it works
best for the chip. Thus, drop port_fdb_getnext and implement the port_fdb_dump
operation in DSA, which pushes the switchdev FDB dump callback down to the
drivers. mv88e6xxx is the only driver affected and is updated accordingly.

Vivien Didelot (6):
  net: dsa: mv88e6xxx: write VID outside of VTU Get Next code
  net: dsa: mv88e6xxx: write MAC outside of ATU Get Next code
  net: dsa: add port_fdb_dump function
  net: dsa: mv88e6xxx: implement port_fdb_dump
  net: dsa: mv88e6xxx: remove port_fdb_getnext
  net: dsa: remove port_fdb_getnext

 drivers/net/dsa/mv88e6171.c |   2 +-
 drivers/net/dsa/mv88e6352.c |   2 +-
 drivers/net/dsa/mv88e6xxx.c | 140 ++++++++++++++++++++++++--------------------
 drivers/net/dsa/mv88e6xxx.h |   5 +-
 include/net/dsa.h           |   8 ++-
 net/dsa/slave.c             |  26 +-------
 6 files changed, 90 insertions(+), 93 deletions(-)

-- 
2.6.1
