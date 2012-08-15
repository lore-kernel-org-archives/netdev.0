From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH 00/14] net: info leaks and other bugs
Date: Wed, 15 Aug 2012 23:31:43 +0200
Message-ID: <1345066317-22512-1-git-send-email-minipli@googlemail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mathias Krause <minipli@googlemail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

this series fixes quite a bunch of info leaks under net/. There is also
one NULL pointer deref fix ("dccp: check ccid before..") that could be
abused for privilege escalation.

The info leak fixes might be material for stable, too. But I leave the
decision up to you.

On request, test code for all (but one) of the issues can be provided.


Regards,
Mathias


Mathias Krause (14):
  atm: fix info leak in getsockopt(SO_ATMPVC)
  atm: fix info leak via getsockname()
  Bluetooth: HCI - Fix info leak in getsockopt(HCI_FILTER)
  Bluetooth: HCI - Fix info leak via getsockname()
  Bluetooth: RFCOMM - Fix info leak in getsockopt(BT_SECURITY)
  Bluetooth: RFCOMM - Fix info leak in ioctl(RFCOMMGETDEVLIST)
  Bluetooth: RFCOMM - Fix info leak via getsockname()
  Bluetooth: L2CAP - Fix info leak via getsockname()
  l2tp: fix info leak via getsockname()
  llc: fix info leak via getsockname()
  dccp: check ccid before dereferencing
  dccp: fix info leak via getsockopt(DCCP_SOCKOPT_CCID_TX_INFO)
  ipvs: fix info leak in getsockopt(IP_VS_SO_GET_TIMEOUT)
  net: fix info leak in compat dev_ifconf()

 net/atm/common.c               |    1 +
 net/atm/pvc.c                  |    1 +
 net/bluetooth/hci_sock.c       |    2 ++
 net/bluetooth/l2cap_sock.c     |    1 +
 net/bluetooth/rfcomm/sock.c    |    2 ++
 net/bluetooth/rfcomm/tty.c     |    2 +-
 net/dccp/ccid.h                |    4 ++--
 net/dccp/ccids/ccid3.c         |    1 +
 net/l2tp/l2tp_ip6.c            |    1 +
 net/llc/af_llc.c               |    3 +--
 net/netfilter/ipvs/ip_vs_ctl.c |    1 +
 net/socket.c                   |    1 +
 12 files changed, 15 insertions(+), 5 deletions(-)

-- 
1.7.10.4
