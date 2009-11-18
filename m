From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Wed, 18 Nov 2009 07:25:06 -0800 (PST)
Message-ID: <20091118.072506.229926265.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757565AbZKRPYw@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Device refcount leak fixes in ROSE and DecNET from Eric Dumazet.

2) IXGBE TX hang fix from Don Skidmore.

3) CXGB3 unmaps DMA buffer too early, fix from Divy Le Ray

4) Wireless fixes via John Linville, in particular a revert of
   the cfg80211 conversion of the ipw2xxx driver as it simply
   broke too much and fixing it is not worth the hassle and risk
   this late in the -rc series.  Also revert the "fix oops on
   missing firmware" change as that broke more than it fixed.

5) Fragmentation disabling busted in IPIP driver when not using
   PMTU discovery, fix from Herbert Xu.

6) Fix SunGEM serdes PHY detection on Sparc.

7) IPMR leaks devices, fix from Dan Carpenter.

8) GRO can merge packets illegally in some circumstances.  Fix from
   Herbert Xu.

9) Locking and error handling fixes in ISDN and Cassini driver from
   Jiri Slaby.

10) CQE_STATUS_EXTD_SHIFT in be2net driver is wrong, fix from Sathya Pe=
rla.
    Also be2net fails to reprogram flow control properly on resume, fro=
m
    Ajit Khaparde.

11) Endian fix in ems_usb from Sebastian Haas.

12) Randomized MAC address is busted in forcedeth driver, use the
    standard interface we provide to do this to fix it.  From
    Stanislav O. Bezzubtsev.

13) Missing driver license tag in fsl_pq_mdio driver leads to taint,
    from Sebastian Siewior.

14) All of bridging code assumes 6 byte addressing, like ethernet,
    so make sure we don't allow configuring bridging on devices that
    use something else otherwise we'll explode.  Fix from Stephen
    Hemminger.

15) Add some new IDs to cdc_ether, from Torgny Johansson.

16) DaVinci EMAC driver passes wrong device pointer to IRQ handler
    from ->poll_controller(), from Tonyliu.

17) SCTP bug fixes pertaining to source address handling and a regressi=
on
    added by the new sctp_conntectx APIs, from Vlad Yasevich.

18) CAN protocol must provide ->get_stats_size() and ->get_xstats_size(=
)
    netlink callbacks, from Wolfgang Grandegger.

19) IXGBE's ->gso_max_size setting is wrong in some circumstances.  Als=
o
    TXOFF status checking is busted when DCB is enabled.  Both from
    Yi Zou.

20) NAT bug fix from Jozsef Kadlecsik.  xt_connlimit regression fix
    from Jan Engelhardt.

21) Non-linear SKBs causes crashes in multilink PPP receive, fix from
    Ben McKeegan.

22) Bluetooth fixes via Marcel Holtmann.

23) Bit shift defines in ibm_newemac driver are completely wrong,
    fix from Dave Mitchell.

Please pull, thanks a lot!

The following changes since commit 7c9abfb884b8737f0afdc8a88bcea77526f0=
da87:
  Linus Torvalds (1):
        Merge branch 'kvm-updates/2.6.32' of git://git.kernel.org/pub/s=
cm/virt/kvm/kvm

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Ajit Khaparde (2):
      be2net: fix to set proper flow control on resume
      be2net: Bug fix to send config commands to hardware after netdev_=
register

Andrei Emeltchenko (1):
      Bluetooth: Set general bonding security for ACL by default

Ben McKeegan (1):
      ppp: fix BUG on non-linear SKB (multilink receive)

Bing Zhao (2):
      Libertas: coding style cleanup in ethtool.c
      Libertas: fix issues while configuring host sleep using ethtool w=
ol

Bob Copeland (3):
      ath5k: don't reset mcast filter when configuring the mode
      ath5k: add LED support for HP Compaq CQ60
      ath5k: add LED definition for BenQ Joybook R55v

Breno Leitao (2):
      s2io: fixing a ethtool test that is broken
      ixgbe: Fixing EEH handler to handle more than one error

Dan Carpenter (2):
      misdn: Fix reversed 'if' in st_own_ctrl
      ipmr: missing dev_put() on error path in vif_add()

Dave Mitchell (1):
      ibm_newemac: Fix EMACx_TRTR[TRT] bit shifts

David S. Miller (5):
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6
      Merge branch 'master' of git://git.kernel.org/.../holtmann/blueto=
oth-2.6
      Revert "isdn: isdn_ppp: Use SKB list facilities instead of home-g=
rown implementation."
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6
      sungem: Fix Serdes detection.

Divy Le Ray (1):
      cxgb3: fix premature page unmap

Don Skidmore (1):
      ixgbe: fix traffic hangs on Tx with ioatdma loaded

Eric Dumazet (5):
      rose: device refcount leak
      decnet: netdevice refcount leak
      can: should not use __dev_get_by_index() without locks
      net: Fix the rollback test in dev_change_name()
      vlan: Fix register_vlan_dev() error path

=46elix Fietkau (1):
      b43: work around a locking issue in ->set_tim()

=46inn Thain (1):
      macsonic: fix crash on PowerBook 520

=46lorian Fainelli (1):
      r6040: fix version printing

Gertjan van Wingerde (1):
      rt2x00: Update MAINTAINERS

Gustavo F. Padovan (2):
      Bluetooth: Select Basic Mode as default for SOCK_SEQPACKET
      Bluetooth: Fix regression with L2CAP configuration in Basic Mode

Herbert Xu (2):
      ipip: Fix handling of DF packets when pmtudisc is OFF
      gro: Fix illegal merging of trailer trash

Ilpo J=E4rvinen (1):
      tcp: provide more information on the tcp receive_queue bugs

Ivo van Doorn (1):
      rt2x00: update MAINTAINERS

Jan Engelhardt (1):
      netfilter: xt_connlimit: fix regression caused by zero family val=
ue

Jiri Slaby (4):
      isdn: hisax: Fix lock imbalance.
      isdn: eicon: Use offsetof
      isdn: eicon: Return on error
      NET: cassini, fix lock imbalance

Joe Perches (2):
      MAINTAINERS: Add git net-next-2.6
      MAINTAINERS: RFKILL - Fix pattern entry missing colon

John W. Linville (2):
      Revert "ipw2200: fix oops on missing firmware"
      Revert "libipw: initiate cfg80211 API conversion"

Jozsef Kadlecsik (1):
      netfilter: nf_nat: fix NAT issue in 2.6.30.4+

Larry Finger (3):
      rtl8187: Fix kernel oops when device is removed when LEDS enabled
      rtl8187: Fix sparse warnings
      p54usb: Remove DMA buffer from stack

Martin Fuzzey (1):
      ssb-pcmcia: Fix 32bit register access in early bus scanning

Martin Michlmayr (1):
      hisax: remove bad udelay call to fix build error on ARM

Oliver Hartkopp (1):
      can: Fix driver Kconfig structure

Raimonds Cicans (1):
      r8169: Fix receive buffer length when MTU is between 1515 and 153=
6

Roel Kluin (3):
      isdn: hisax: Fix test in waitforxfw
      isdn: hfc_usb: Fix read buffer overflow
      mISDN: fix error return in HFCmulti_init()

Ron Mercer (2):
      qlge: Fix early exit from mbox cmd complete wait.
      qlge: Set PCIe reset type for EEH to fundamental.

Sathya Perla (1):
      be2net: Fix CQE_STATUS_EXTD_SHIFT define

Sean Cross (1):
      rt2x00: Don't queue ieee80211 work after USB removal

Sebastian Haas (1):
      ems_usb: Fix byte order issues on big endian machines

Sebastian Siewior (1):
      net/fsl_pq_mdio: add module license GPL

Sriram (2):
      smsc911x: Fix Console Hang when bringing the interface down.
      TI Davinci EMAC : Fix Console Hang when bringing the interface do=
wn

Stanislav O. Bezzubtsev (1):
      forcedeth: mac address fix

Stephen Hemminger (1):
      bridge: prevent bridging wrong device

Stephen Rothwell (1):
      net: fix mdio section mismatch warning

Tonyliu (1):
      DaVinci EMAC: correct param for ISR

Torgny Johansson (1):
      cdc_ether: additional Ericsson MBM PID's to the whitelist

Uwe Kleine-K=F6nig (1):
      virtio_net: rename driver struct to please modpost

Vlad Yasevich (3):
      sctp: Set source addresses on the association before adding trans=
ports
      sctp: Fix regression introduced by new sctp_connectx api
      sctp: Set socket source address when additing first transport

Wey-Yi Guy (2):
      iwlwifi: Use RTS/CTS as the preferred protection mechanism for 60=
00 series
      iwlwifi: Fix issue on file transfer stalled in HT mode

Wolfgang Grandegger (2):
      can: fix WARN_ON dump in net/core/rtnetlink.c:rtmsg_ifinfo()
      can: add the missing netlink get_xstats_size callback

Yi Zou (2):
      ixgbe: Fix gso_max_size for 82599 when DCB is enabled
      ixgbe: Fix checking TFCS register for TXOFF status when DCB is en=
abled

 MAINTAINERS                                   |    5 +-
 drivers/isdn/hardware/eicon/maintidi.c        |    5 +-
 drivers/isdn/hardware/eicon/message.c         |   18 +-
 drivers/isdn/hardware/mISDN/hfcmulti.c        |    2 +-
 drivers/isdn/hisax/amd7930_fn.c               |    1 +
 drivers/isdn/hisax/diva.c                     |    2 +-
 drivers/isdn/hisax/elsa_ser.c                 |   22 +-
 drivers/isdn/hisax/hfc_usb.c                  |    4 +-
 drivers/isdn/hisax/hscx_irq.c                 |    2 +-
 drivers/isdn/hisax/icc.c                      |    1 +
 drivers/isdn/i4l/isdn_ppp.c                   |  352 ++++++++++++-----=
--------
 drivers/isdn/mISDN/stack.c                    |    2 +-
 drivers/net/benet/be.h                        |    2 +
 drivers/net/benet/be_cmds.h                   |    2 +-
 drivers/net/benet/be_ethtool.c                |    8 +-
 drivers/net/benet/be_main.c                   |   28 ++-
 drivers/net/can/Kconfig                       |   60 +----
 drivers/net/can/dev.c                         |   23 ++
 drivers/net/can/sja1000/Kconfig               |   47 ++++
 drivers/net/can/usb/Kconfig                   |   10 +
 drivers/net/can/usb/Makefile                  |    2 +
 drivers/net/can/usb/ems_usb.c                 |    5 +-
 drivers/net/cassini.c                         |    5 +-
 drivers/net/cxgb3/sge.c                       |    4 +-
 drivers/net/davinci_emac.c                    |    5 +-
 drivers/net/forcedeth.c                       |    5 +-
 drivers/net/fsl_pq_mdio.c                     |    1 +
 drivers/net/ibm_newemac/emac.h                |    4 +-
 drivers/net/ixgbe/ixgbe_main.c                |   85 ++++++-
 drivers/net/macsonic.c                        |  117 +++++----
 drivers/net/phy/mdio-gpio.c                   |    2 +-
 drivers/net/ppp_generic.c                     |   11 +-
 drivers/net/qlge/qlge_main.c                  |    2 +
 drivers/net/qlge/qlge_mpi.c                   |    2 +-
 drivers/net/r6040.c                           |    2 +-
 drivers/net/r8169.c                           |    4 +-
 drivers/net/s2io.c                            |    1 +
 drivers/net/smsc911x.c                        |    2 +-
 drivers/net/sungem.c                          |   10 +-
 drivers/net/usb/Kconfig                       |    2 +-
 drivers/net/usb/cdc_ether.c                   |   42 +++-
 drivers/net/virtio_net.c                      |    6 +-
 drivers/net/wireless/ath/ath5k/base.c         |    1 -
 drivers/net/wireless/ath/ath5k/led.c          |    4 +
 drivers/net/wireless/b43/main.c               |    3 +-
 drivers/net/wireless/ipw2x00/ipw2100.c        |   11 +-
 drivers/net/wireless/ipw2x00/ipw2200.c        |  143 ++--------
 drivers/net/wireless/ipw2x00/libipw.h         |    9 +-
 drivers/net/wireless/ipw2x00/libipw_module.c  |   46 +---
 drivers/net/wireless/iwlwifi/iwl-1000.c       |    1 +
 drivers/net/wireless/iwlwifi/iwl-6000.c       |    5 +
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c     |    9 +
 drivers/net/wireless/iwlwifi/iwl-agn.c        |   10 +-
 drivers/net/wireless/iwlwifi/iwl-core.h       |    2 +
 drivers/net/wireless/libertas/ethtool.c       |   17 +-
 drivers/net/wireless/p54/p54usb.c             |   10 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c       |    4 +-
 drivers/net/wireless/rt2x00/rt2x00link.c      |   11 +-
 drivers/net/wireless/rt2x00/rt2x00usb.c       |    9 +-
 drivers/net/wireless/rtl818x/rtl8187_leds.c   |    4 +-
 drivers/net/wireless/rtl818x/rtl8187_rfkill.c |    1 +
 drivers/ssb/scan.c                            |    6 +-
 include/linux/isdn_ppp.h                      |    2 +-
 include/net/netfilter/nf_conntrack.h          |    8 +-
 include/net/netfilter/nf_nat_helper.h         |    4 +
 include/net/sctp/structs.h                    |    2 +-
 net/8021q/vlan.c                              |    7 +-
 net/bluetooth/hci_conn.c                      |    1 +
 net/bluetooth/l2cap.c                         |   13 +-
 net/bridge/br_if.c                            |    6 +-
 net/can/bcm.c                                 |   19 +-
 net/core/dev.c                                |   11 +-
 net/core/skbuff.c                             |    3 +-
 net/decnet/sysctl_net_decnet.c                |    7 +-
 net/ipv4/ipip.c                               |   32 ++-
 net/ipv4/ipmr.c                               |    4 +-
 net/ipv4/netfilter/nf_nat_core.c              |    3 +
 net/ipv4/netfilter/nf_nat_helper.c            |   34 ++-
 net/ipv4/tcp.c                                |   19 +-
 net/netfilter/nf_conntrack_core.c             |    8 +
 net/netfilter/nf_conntrack_proto_tcp.c        |   64 ++---
 net/netfilter/xt_connlimit.c                  |   10 +-
 net/rose/rose_route.c                         |   16 +-
 net/sctp/associola.c                          |    4 +-
 net/sctp/sm_statefuns.c                       |   15 +-
 net/sctp/socket.c                             |   40 ++-
 net/sctp/transport.c                          |    3 +-
 87 files changed, 834 insertions(+), 722 deletions(-)
 create mode 100644 drivers/net/can/sja1000/Kconfig
 create mode 100644 drivers/net/can/usb/Kconfig
