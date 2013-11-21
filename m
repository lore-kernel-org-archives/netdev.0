From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Thu, 21 Nov 2013 14:26:16 -0500 (EST)
Message-ID: <20131121.142616.1651417691142591081.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Fix memory leaks and other issues in mwifiex driver, from Amitkumar
   Karwar.

2) skb_segment() can choke on packets using frag lists, fix from
   Herbert Xu with help from Eric Dumazet and others.

3) IPv4 output cached route instantiation properly handles races
   involving two threads trying to install the same route, but we
   forgot to propagate this logic to input routes as well.  Fix
   from Alexei Starovoitov.

4) Put protections in place to make sure that recvmsg() paths never
   accidently copy uninitialized memory back into userspace and also
   make sure that we never try to use more that sockaddr_storage for
   building the on-kernel-stack copy of a sockaddr.  Fixes from Hannes
   Frederic Sowa.

5) R8152 driver transmit flow bug fixes from Hayes Wang.

6) Fix some minor fallouts from genetlink changes, from Johannes Berg
   and Michael Opdenacker.

7) AF_PACKET sendmsg path can race with netdevice unregister notifier,
   fix by using RCU to make sure the network device doesn't go away
   from under us.  Fix from Daniel Borkmann.

Please pull, thanks a lot!

The following changes since commit b4789b8e6be3151a955ade74872822f30e8c=
d914:

  aacraid: prevent invalid pointer dereference (2013-11-19 16:27:39 -08=
00)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to 9d8506cc2d7ea1f911c72c100193a3677f6668c3=
:

  gso: handle new frag_list of frags GRO packets (2013-11-21 14:11:50 -=
0500)

----------------------------------------------------------------
Alexei Starovoitov (1):
      ipv4: fix race in concurrent ip_route_input_slow()

Amitkumar Karwar (5):
      mwifiex: use return value of mwifiex_add_virtual_intf() correctly
      mwifiex: failure path handling in mwifiex_add_virtual_intf()
      mwifiex: fix NULL pointer dereference in mwifiex_fw_dpc
      mwifiex: fix potential mem leak in .del_virtual_intf
      mwifiex: fix memory leak issue for sdio and pcie cards

Andy Fleming (1):
      net/phy: Add VSC8234 support

Daniel Borkmann (1):
      packet: fix use after free race in send path when dev is released

David S. Miller (3):
      Merge branch 'r8152'
      Merge branch 'master' of git://git.kernel.org/.../pablo/nf
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wir=
eless

David Vrabel (1):
      xen-netback: stop the VIF thread before unbinding IRQs

Ding Tianhong (1):
      bridge: flush br's address entry in fdb when remove the

=46elix Fietkau (1):
      rt2x00: fix a crash bug in the HT descriptor handling fix

Geyslan G. Bem (1):
      brcmfmac: fix possible memory leak

Hannes Frederic Sowa (2):
      net: rework recvmsg handler msg_name and msg_namelen logic
      net: add BUG_ON if kernel advertises msg_namelen > sizeof(struct =
sockaddr_storage)

Herbert Xu (1):
      gso: handle new frag_list of frags GRO packets

Johan Hedberg (1):
      Bluetooth: Fix rejecting SMP security request in slave role

Johannes Berg (2):
      genetlink: fix genlmsg_multicast() bug
      genetlink: fix genl_set_err() group ID

John W. Linville (2):
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth=
/bluetooth
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem

Larry Finger (1):
      rtlwifi: rtl8192cu: Fix more pointer arithmetic errors

Luis R. Rodriguez (1):
      ath: fix dynamic user regulatory settings

Lu=EDs Fernando Cornachioni Estrozi (1):
      netfilter: ebt_ip6: fix source and destination matching

Madalin Bucur (1):
      net/phy: Add the autocross feature for forced links on VSC82x4

Marcel Holtmann (1):
      Bluetooth: Fix issue with RFCOMM getsockopt operation

Martin Topholm (2):
      netfilter: synproxy: send mss option to backend
      netfilter: synproxy: correct wscale option passing

Michael Opdenacker (1):
      wimax: remove dead code

Pablo Neira Ayuso (2):
      netfilter: nft_compat: fix error path in nft_parse_compat()
      netfilter: nf_conntrack: decrement global counter after object re=
lease

Phil Oester (1):
      netfilter: fix wrong byte order in nf_ct_seqadj_set internal info=
rmation

Randy Dunlap (1):
      netfilter: fix connlimit Kconfig prompt string

Sandeep Singh (1):
      net/phy: Add VSC8662 support

Seung-Woo Kim (3):
      Bluetooth: Fix RFCOMM bind fail for L2CAP sock
      Bluetooth: Fix to set proper bdaddr_type for RFCOMM connect
      Bluetooth: Fix crash in l2cap_chan_send after l2cap_chan_del

Sujith Manoharan (2):
      ath9k: Update AR9462 2.1 initvals
      ath9k: Fix issue with MCS15

Ujjal Roy (1):
      mwifiex: fix issues in driver unload path for USB chipsets

Vlad Yasevich (1):
      net: core: Always propagate flag changes to interfaces

hayeswang (4):
      r8152: fix tx/rx memory overflow
      r8152: modify the tx flow
      r8152: support stopping/waking tx queue
      r8152: fix incorrect type in assignment

shaohui xie (1):
      net/phy: Add VSC8574 support

 crypto/algif_hash.c                                  |   2 -
 crypto/algif_skcipher.c                              |   1 -
 drivers/isdn/mISDN/socket.c                          |  13 ++-----
 drivers/net/phy/phy_device.c                         |   4 +-
 drivers/net/phy/vitesse.c                            | 117 +++++++++++=
+++++++++++++++++++++++++++++++++++++++++++++--
 drivers/net/ppp/pppoe.c                              |   2 -
 drivers/net/usb/r8152.c                              | 114 +++++++++++=
++++++++++++++-------------------------------
 drivers/net/wireless/ath/ath9k/ar9003_phy.c          |  50 +++++++++++=
++++++++++++++
 drivers/net/wireless/ath/ath9k/ar9003_phy.h          |  11 ++++++
 drivers/net/wireless/ath/ath9k/ar9462_2p1_initvals.h |   6 +--
 drivers/net/wireless/ath/regd.c                      |   3 +-
 drivers/net/wireless/brcm80211/brcmfmac/p2p.c        |   1 +
 drivers/net/wireless/mwifiex/cfg80211.c              |  23 ++++++++++-=
-
 drivers/net/wireless/mwifiex/main.c                  |  28 ++++-------=
---
 drivers/net/wireless/mwifiex/pcie.c                  |   2 +-
 drivers/net/wireless/mwifiex/sdio.c                  |   7 ++--
 drivers/net/wireless/mwifiex/usb.c                   |  27 ++++++++---=
---
 drivers/net/wireless/rt2x00/rt2x00dev.c              |   3 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.c         |   6 +--
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.c         |   6 +--
 drivers/net/xen-netback/interface.c                  |   6 +--
 include/linux/net.h                                  |   8 ++++
 include/linux/phy.h                                  |   1 +
 include/net/genetlink.h                              |   8 ++--
 net/appletalk/ddp.c                                  |  16 ++++----
 net/atm/common.c                                     |   2 -
 net/ax25/af_ax25.c                                   |   4 +-
 net/bluetooth/af_bluetooth.c                         |   9 +----
 net/bluetooth/hci_sock.c                             |   2 -
 net/bluetooth/l2cap_core.c                           |   3 ++
 net/bluetooth/rfcomm/core.c                          |   3 ++
 net/bluetooth/rfcomm/sock.c                          |   7 +++-
 net/bluetooth/sco.c                                  |   1 -
 net/bluetooth/smp.c                                  |   3 ++
 net/bridge/br_if.c                                   |   2 +
 net/bridge/netfilter/ebt_ip6.c                       |   8 ++--
 net/caif/caif_socket.c                               |   4 --
 net/compat.c                                         |   3 +-
 net/core/dev.c                                       |   2 +-
 net/core/iovec.c                                     |   3 +-
 net/core/skbuff.c                                    |  75 +++++++++++=
+++++++++++++-------------
 net/ipv4/netfilter/ipt_SYNPROXY.c                    |   1 +
 net/ipv4/route.c                                     |   8 +++-
 net/ipv6/netfilter/ip6t_SYNPROXY.c                   |   1 +
 net/ipx/af_ipx.c                                     |   3 +-
 net/irda/af_irda.c                                   |   4 --
 net/iucv/af_iucv.c                                   |   2 -
 net/key/af_key.c                                     |   1 -
 net/l2tp/l2tp_ppp.c                                  |   2 -
 net/llc/af_llc.c                                     |   2 -
 net/netfilter/Kconfig                                |   2 +-
 net/netfilter/nf_conntrack_core.c                    |   3 +-
 net/netfilter/nf_conntrack_seqadj.c                  |   4 +-
 net/netfilter/nf_synproxy_core.c                     |   7 ++--
 net/netfilter/nft_compat.c                           |  19 +++++++---
 net/netlink/af_netlink.c                             |   2 -
 net/netlink/genetlink.c                              |   4 +-
 net/netrom/af_netrom.c                               |   3 +-
 net/nfc/llcp_sock.c                                  |   2 -
 net/nfc/rawsock.c                                    |   2 -
 net/packet/af_packet.c                               |  91 +++++++++++=
++++++++++++++--------------------
 net/packet/internal.h                                |   1 +
 net/rds/recv.c                                       |   2 -
 net/rose/af_rose.c                                   |   8 ++--
 net/rxrpc/ar-recvmsg.c                               |   9 +++--
 net/socket.c                                         |  22 ++++++-----
 net/tipc/socket.c                                    |   6 ---
 net/unix/af_unix.c                                   |   5 ---
 net/vmw_vsock/af_vsock.c                             |   2 -
 net/vmw_vsock/vmci_transport.c                       |   2 -
 net/wimax/stack.c                                    |   1 -
 net/x25/af_x25.c                                     |   3 +-
 72 files changed, 504 insertions(+), 316 deletions(-)
