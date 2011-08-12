From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 12 Aug 2011 03:33:09 -0700 (PDT)
Message-ID: <20110812.033309.210496433188639417.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Alternate MAC doesn't work on some E1000E chips, from Bruce Allan.

2) bnx2x fixes from Vladislav Zolotarov and Dmitry Kravkov including a =
fix
   for queue selection when FCOE is disabled.

3) Some uses of rt->rt_iif should be rt->rt_route_iif, from Julian
   Anastasov.

4) Fix ebt_register_table() error unwind, from Julia Lawall.

5) Similarly for netlabel's netlbl_cfg_cipsov4_map_add().

6) Build fixes for SH IRDA drivers, from Kuninori Morimoto.

7) If cookie_check_timestamp() fails in some cases, we leave "ecn_ok"
   uninitialized but then test it.  From Mike Waychison.

8) __scm_send() accidently captures UID instead of GID in credentials,
   fix from Tim Chen.

9) Fix leak in wl1251 wireless, from Julia Lawall.

10) PRIO packet scheduler needs to use qdisc_dequeue_peeked(), from Flo=
wian
    Westphal.

11) ath5k_beacon_send() needs better error handling, from Bob Copeland.

12) Add device IDs to rt2x00 USB wireless.

13) Correct source address semantics on ipv4 raw sockets, from Julian
    Anastasov.

14) Packets looped back need to grab a reference to their attached rout=
e.
    Also from Julian Anastasov.

15) ip_route_me_harder() fix for packets coming from the global RAW soc=
ket
    TCP uses to send resets and some ACKs.  From Julian Anastasov.

16) Fix compat handling for IP_PKTOPTIONS, from Daniel Baluta.

17) Add missing compat entry from PPPIOCGL2TPSTATS, from Florian Westph=
al.

18) Fix crash when input route accidently used for output, from Julian
    Anastasov.

19) SLIP/SLCAN need to use netif_rx_ni() because of the context in whic=
h
    TTY buffers are signalled.  From Matvejchikov Ilya and Oliver Hartk=
opp.

20) Fix double-free in nf_reinject.  From Julian Anastasov.

Please pull, thanks a lot!

The following changes since commit eeca7360f756f7e36e846f35018df20808c7=
ef63:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc (2011=
-08-12 00:35:46 -0700)

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net.git master

Alex Hacker (1):
      ath9k: fix a misprint which leads to incorrect calibration

Andrei Warkentin (1):
      Bridge: Always send NETDEV_CHANGEADDR up on br MAC change.

Anthony Bourguignon (1):
      rt2x00: Add rt2870 device id for Dvico usb key

Bob Copeland (1):
      ath5k: fix error handling in ath5k_beacon_send

Bruce Allan (4):
      e1000e: alternate MAC address does not work on device id 0x1060
      e1000e: do not disable receiver on 82574/82583
      e1000e: alternate MAC address update
      e1000e: increase driver version number

Daniel Baluta (1):
      ipv4: Fix ip_getsockopt for IP_PKTOPTIONS

David S. Miller (2):
      net: Make userland include of netlink.h more sane.
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wir=
eless

Dmitry Kravkov (3):
      bnx2x: prevent race between undi_unload and load flows
      bnx2x: properly clean indirect addresses
      bnx2x: disable dcb on 578xx since not supported yet

=46lorian Westphal (2):
      compat_ioctl: add compat handler for PPPIOCGL2TPSTATS
      net_sched: prio: use qdisc_dequeue_peeked

Hauke Mehrtens (1):
      b43: read correct register on bcma bus.

Ivo van Doorn (1):
      rt2x00: Add new rt73 buffalo USB id

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem

Julia Lawall (3):
      drivers/net/wireless/wl1251: add missing kfree
      net/netlabel/netlabel_kapi.c: add missing cleanup code
      net/bridge/netfilter/ebtables.c: use available error handling cod=
e

Julian Anastasov (6):
      netfilter: avoid double free in nf_reinject
      ipv4: fix the reusing of routing cache entries
      netfilter: TCP and raw fix for ip_route_me_harder
      ipv4: route non-local sources for raw socket
      ipv4: use dst with ref during bcast/mcast loopback
      ipv4: some rt_iif -> rt_route_iif conversions

Kuninori Morimoto (3):
      net/irda: sh_irda: add missing header
      net/irda: sh_sir: add missing header
      net/irda: sh_sir: tidyup compile warning

Larry Finger (1):
      rtlwifi: rtl892cu: New USB IDs

Matvejchikov Ilya (1):
      slip: fix NOHZ local_softirq_pending 08 warning

Mike Waychison (1):
      tcp: initialize variable ecn_ok in syncookies path

Nicolas de Peslo=FCan (1):
      bonding: document two undocumented options.

Oliver Hartkopp (1):
      slcan: ldisc generated skbs are received in softirq context

Rajkumar Manoharan (2):
      ath9k_hw: Fix incorrect Tx control power in AR9003 template
      ath9k_hw: update PMU to improve ripple issue for AR9485

Ralf Baechle (1):
      PCnet: Fix section mismatch

Richard Cochran (2):
      gianfar: fix fiper alignment after resetting the time
      dp83640: increase receive time stamp buffer size

Tim Chen (1):
      scm: Capture the full credentials of the scm sender

Vladislav Zolotarov (2):
      bnx2x: init FCOE FP only once
      bnx2x: fix select_queue when FCoE is disabled

Willem de Bruijn (1):
      net: add Documentation/networking/scaling.txt

huajun li (1):
      rtl8150: rtl8150_disconnect(...) does not need tasklet_disable(..=
=2E)

 Documentation/networking/bonding.txt           |   29 ++
 Documentation/networking/scaling.txt           |  371 ++++++++++++++++=
++++++++
 drivers/net/bnx2x/bnx2x_cmn.c                  |   35 ++-
 drivers/net/bnx2x/bnx2x_dcb.c                  |    2 +-
 drivers/net/bnx2x/bnx2x_main.c                 |   23 ++-
 drivers/net/bnx2x/bnx2x_reg.h                  |   26 ++-
 drivers/net/can/slcan.c                        |    2 +-
 drivers/net/e1000e/82571.c                     |    6 +-
 drivers/net/e1000e/e1000.h                     |    1 +
 drivers/net/e1000e/ethtool.c                   |    3 +-
 drivers/net/e1000e/lib.c                       |    7 +-
 drivers/net/e1000e/netdev.c                    |    9 +-
 drivers/net/gianfar_ptp.c                      |    9 +-
 drivers/net/irda/sh_irda.c                     |    2 +
 drivers/net/irda/sh_sir.c                      |    4 +-
 drivers/net/pcnet32.c                          |    2 +-
 drivers/net/phy/dp83640.c                      |    5 +-
 drivers/net/slip.c                             |    2 +-
 drivers/net/usb/rtl8150.c                      |    1 -
 drivers/net/wireless/ath/ath5k/base.c          |   23 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c |    8 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.h    |    2 +-
 drivers/net/wireless/b43/dma.c                 |   20 +-
 drivers/net/wireless/rt2x00/rt2800usb.c        |    2 +
 drivers/net/wireless/rt2x00/rt73usb.c          |    1 +
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c    |   11 +-
 drivers/net/wireless/wl1251/acx.c              |    6 +-
 drivers/net/wireless/wl1251/cmd.c              |    2 +-
 fs/compat_ioctl.c                              |    1 +
 include/linux/netlink.h                        |    2 +-
 include/linux/socket.h                         |    6 +-
 include/net/inet_sock.h                        |    2 +-
 net/bridge/br_if.c                             |    6 +-
 net/bridge/br_notify.c                         |    7 +-
 net/bridge/netfilter/ebtables.c                |    3 +-
 net/core/scm.c                                 |    2 +-
 net/ipv4/ip_output.c                           |    1 +
 net/ipv4/ip_sockglue.c                         |    9 +-
 net/ipv4/netfilter.c                           |   18 +-
 net/ipv4/raw.c                                 |    3 +-
 net/ipv4/route.c                               |    9 +-
 net/ipv4/syncookies.c                          |    2 +-
 net/ipv6/syncookies.c                          |    2 +-
 net/netfilter/nf_queue.c                       |    1 +
 net/netlabel/netlabel_kapi.c                   |   20 +-
 net/sched/sch_prio.c                           |    2 +-
 46 files changed, 604 insertions(+), 106 deletions(-)
 create mode 100644 Documentation/networking/scaling.txt
