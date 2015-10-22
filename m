From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v4 0/6] net: dsa: implement port_fdb_dump in drivers
Date: Thu, 22 Oct 2015 09:34:37 -0400
Message-ID: <1445520883-13287-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Not all switch chips provide a Get Next kind of operation to dump FDB entries.
It is preferred to let the driver handle the dump operation the way it works
best for the chip. Thus, drop port_fdb_getnext and implement the port_fdb_dump
operation in DSA, which pushes the switchdev FDB dump callback down to the
drivers. mv88e6xxx is the only driver affected and is updated accordingly.

v3 -> v4: fix rejects on latest net-next

v2 -> v3: opencode switchdev_obj_dump_cb_t to avoid multiple typedef;
          use ether_addr_copy in fdb_dump

v1 -> v2: fix a few "return err" instead of "goto unlock" in mv88e6xxx.c

Vivien Didelot (6):
  net: dsa: add port_fdb_dump function
  net: dsa: mv88e6xxx: write VID outside of VTU Get Next code
  net: dsa: mv88e6xxx: write MAC outside of ATU Get Next code
  net: dsa: mv88e6xxx: implement port_fdb_dump
  net: dsa: mv88e6xxx: remove port_fdb_getnext
  net: dsa: remove port_fdb_getnext

 drivers/net/dsa/mv88e6171.c |   2 +-
 drivers/net/dsa/mv88e6352.c |   2 +-
 drivers/net/dsa/mv88e6xxx.c | 132 ++++++++++++++++++++++++--------------------
 drivers/net/dsa/mv88e6xxx.h |   5 +-
 include/net/dsa.h           |   7 ++-
 net/dsa/slave.c             |  26 +--------
 6 files changed, 83 insertions(+), 91 deletions(-)

-- 
2.6.1
