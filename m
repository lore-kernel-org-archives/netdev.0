From: Anton Nayshtut <Anton.Nayshtut@wilocity.com>
Subject: [PATCH 0/4] bonding: L2DA mode
Date: Thu, 21 Nov 2013 16:55:34 +0200
Message-ID: <1385045738-29726-1-git-send-email-Anton.Nayshtut@wilocity.com>
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Anton Nayshtut <Anton.Nayshtut@wilocity.com>
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Nicolas Schichan <nschichan@freebox.fr>,
	Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

L2 Destination Address based (L2DA) mode allows bonding to send packets using
different slaves according to packets L2 Destination Address.

In L2DA mode, the bonding maintains a default slave and DA/slave map.

Upon a packet transmission, the bonding examines DA of the packet and tries to
find a corresponding slave within the map. If found, the slave is used for the
packet transmission. Otherwise, the default slave is used. If the default slave
is unable to transmit at this moment, the bonding tries to fall back to an
arbitrary slave that can transmit.

Both the default slave and the map can be controlled via sysfs or by ioctls.

Anton Nayshtut (4):
  bonding: L2DA mode added
  bonding: L2DA mode intergated
  bonding: L2DA command IOCTL
  bonding: L2DA query IOCTL

 drivers/net/bonding/Makefile       |   2 +-
 drivers/net/bonding/bond_l2da.c    | 425 +++++++++++++++++++++++++++++++++++++
 drivers/net/bonding/bond_l2da.h    |  56 +++++
 drivers/net/bonding/bond_main.c    | 172 ++++++++++++++-
 drivers/net/bonding/bond_options.c |  17 +-
 drivers/net/bonding/bond_sysfs.c   | 223 ++++++++++++++++++-
 drivers/net/bonding/bonding.h      |   7 +
 include/uapi/linux/if_bonding.h    |  32 +++
 include/uapi/linux/sockios.h       |   4 +-
 net/core/dev_ioctl.c               |   4 +
 net/socket.c                       |   4 +
 11 files changed, 937 insertions(+), 9 deletions(-)
 create mode 100644 drivers/net/bonding/bond_l2da.c
 create mode 100644 drivers/net/bonding/bond_l2da.h

-- 
1.8.3.1
