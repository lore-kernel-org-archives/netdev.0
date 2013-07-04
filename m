From: Kyle Manna <kyle@kylemanna.com>
Subject: [PATCH 0/2] Add support fo BT LE Connection Parameters
Date: Thu,  4 Jul 2013 16:25:01 -0700
Message-ID: <1372980303-3007-1-git-send-email-kyle@kylemanna.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Kyle Manna <kyle@kylemanna.com>
To: linux-bluetooth@vger.kernel.org,
	Marcel Holtmann <marcel@holtmann.org>,
	Gustavo Padovan <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series adds support for calling setsockopt() on a l2cap socket to set connection parameters prior to calling connect().

The motivation for setting the paremeters prior to connect is to:
1) Reduce the issues caused with BT and WiFi hardware radios that share the same antenna.  During the connection, typically the WiFi portion of the radio is blocked. Setting the connection parameters such as the window and interval allow the userspace app to tune and compromise.
2) Eliminate the need to call HCI connection update when the paremeters are known ahead of time.

Kyle Manna (2):
  bluetooth: Pass HCI LE connection parameters
  bluetooth: Add l2cap sockopt for LE conn params

 include/net/bluetooth/bluetooth.h |  2 ++
 include/net/bluetooth/hci_core.h  |  5 +++--
 include/net/bluetooth/l2cap.h     |  2 ++
 net/bluetooth/hci_conn.c          | 33 ++++++++++++++-------------------
 net/bluetooth/l2cap_core.c        | 13 +++++++++++--
 net/bluetooth/l2cap_sock.c        | 25 +++++++++++++++++++++++++
 net/bluetooth/mgmt.c              |  4 ++--
 net/bluetooth/sco.c               |  2 +-
 8 files changed, 60 insertions(+), 26 deletions(-)

-- 
1.8.1.2
