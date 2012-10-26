From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 26 Oct 2012 17:38:52 -0400 (EDT)
Message-ID: <20121026.173852.1809902507192213708.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This is what we usually expect at this stage of the game, lots of
little things, mostly in drivers.  With the occaisional "oops didn't
mean to do that" kind of regressions in the core code.

1) Uninitialized data in __ip_vs_get_timeouts(), from Arnd Bergmann

2) Reject invalid ACK sequences in Fast Open sockets, from Jerry Chu.

3) Lost error code on return from _rtl_usb_receive(), from Christian
   Lamparter.

4) Fix reset resume on USB rt2x00, from Stanislaw Gruszka.

5) Release resources on error in pch_gbe driver, from Veaceslav Falico.

6) Default hop limit not set correctly in ip6_template_metrics[], fix
   from Li RongQing.

7) Gianfar PTP code requests wrong kind of resource during probe,
   fix from Wei Yang.

8) Fix VHOST net driver on big-endian, from Michael S. Tsirkin.

9) Mallenox driver bug fixes from Jack Morgenstein, Or Gerlitz,
   Moni Shoua, Dotan Barak, and Uri Habusha.

10) usbnet leaks memory on TX path, fix from Hemant Kumar.

11) Use socket state test, rather than presence of FIN bit packet,
    to determine FIONREAD/SIOCINQ value.  Fix from Eric Dumazet.

12) Fix cxgb4 build failure, from Vipul Pandya.

13) Provide a SYN_DATA_ACKED state to complement SYN_FASTOPEN in socket
    info dumps.  From Yuchung Cheng.

14) Fix leak of security path in kfree_skb_partial().  Fix from
    Eric Dumazet.

15) Handle RX FIFO overflows more resiliently in pch_gbe driver, from
    Veaceslav Falico.

16) Fix MAINTAINERS file pattern for networking drivers, from Jean
    Delvare.

17) Add iPhone5 IDs to IPHETH driver, from Jay Purohit.

18) VLAN device type change restriction is too strict, and should not
    trigger for the automatically generated vlan0 device.  Fix from
    Jiri Pirko.

19) Make PMTU/redirect flushing work properly again in ipv4, from Steff=
en
    Klassert.

20) Fix memory corruptions by using kfree_rcu() in netlink_release().
    From Eric Dumazet.

21) More qmi_wwan device IDs, from Bj=F8rn Mork.

22) Fix unintentional change of SNAT/DNAT hooks in generic NAT
    infrastructure, from Elison Niven.

23) Fix 3.6.x regression in xt_TEE netfilter module, from Eric Dumazet.

Please pull, thanks a lot!

The following changes since commit 43c422eda99b894f18d1cca17bcd2401efaf=
7bd0:

  apparmor: fix apparmor OOPS in audit_log_untrustedstring+0x1c/0x40 (2=
012-10-17 16:29:46 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to 330ee00412bbaefa7d0597a1bed7804e818ba91c=
:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/gi=
t/linville/wireless into for-davem (2012-10-26 10:32:13 -0400)

----------------------------------------------------------------

Arnd Bergmann (1):
      ipvs: initialize returned data in do_ip_vs_get_ctl

Bing Zhao (2):
      mwifiex: return -EBUSY if specific scan request cannot be honored
      mwifiex: clean up scan state on error

Bj=F8rn Mork (1):
      net: qmi_wwan: adding more ZTE devices

Chris Metcalf (1):
      tilegx: fix some issues in the SW TSO support

Christian Lamparter (1):
      rtlwifi: pass rx setup error code to caller

Dan Carpenter (1):
      brcmfmac: fix end of loop check (signedness bug)

Dan Williams (1):
      qmi_wwan/cdc_ether: move Novatel 551 and E362 to qmi_wwan

David S. Miller (4):
      Merge branch 'master' of git://1984.lsi.us.es/nf
      Merge tag 'batman-adv-fix-for-davem' of git://git.open-mesh.org/l=
inux-merge
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wir=
eless
      Merge branch 'fixes-for-3.7' of git://gitorious.org/linux-can/lin=
ux-can

Dotan Barak (1):
      net/mlx4_core: Unmap UAR also in the case of error flow

Elison Niven (1):
      netfilter: xt_nat: fix incorrect hooks for SNAT and DNAT targets

Eric Dumazet (4):
      netfilter: xt_TEE: don't use destination address found in header
      netlink: use kfree_rcu() in netlink_release()
      tcp: fix FIONREAD/SIOCINQ
      net: fix secpath kmemleak

=46elix Fietkau (2):
      mac80211: use ieee80211_free_txskb in a few more places
      Revert "ath9k_hw: Updated AR9003 tx gain table for 5GHz"

=46ranky Lin (2):
      brcmfmac: use control channel in roamed status reporting
      brcmfmac: set dongle mode accordingly when interface up

Hante Meuleman (1):
      brcmfmac: handle all exceptions as an error.

Hemant Kumar (1):
      net: usb: Fix memory leak on Tx data path

Jack Morgenstein (1):
      net/mlx4_en: Fix double-release-range in tx-rings

Jay Purohit (1):
      usb/ipheth: Add iPhone 5 support

Jean Delvare (1):
      MAINTAINERS: NETWORKING DRIVERS matches too much

Jerry Chu (1):
      tcp: Reject invalid ack_seq to Fast Open sockets

Jiri Pirko (1):
      vlan: allow to change type when no vlan device is hooked on netde=
v

Joe Jin (1):
      qla3xxx: Ensure request/response queue addr writes to the registe=
rs

Johan Hedberg (1):
      Bluetooth: SMP: Fix setting unknown auth_req bits

Johannes Berg (3):
      Merge remote-tracking branch 'wireless/master' into mac80211
      iwlwifi: fix 6000 series channel switch command
      mac80211: connect with HT20 if HT40 is not permitted

John W. Linville (4):
      Merge branch 'master' of git://git.kernel.org/.../bluetooth/bluet=
ooth
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac8021=
1
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem

Jouni Malinen (1):
      mac80211: Fix FC masking in BIP AAD generation

Larry Finger (1):
      b43: Fix oops on unload when firmware not found

Li RongQing (1):
      ipv6: Set default hoplimit as zero.

Linus L=FCssing (2):
      batman-adv: Fix broadcast packet CRC calculation
      batman-adv: Fix potential broadcast BLA-duplicate-check race cond=
ition

Matus Ujhelyi (1):
      phy: add AT803x driver

Michael S. Tsirkin (1):
      vhost: fix mergeable bufs on BE hosts

Mohammed Shafi Shajakhan (1):
      ath9k_htc: Add PID/VID for a Ubiquiti WiFiStation

Moni Shoua (1):
      net/mlx4_en: Don't use vlan tag value as an indication for vlan p=
resence

Pablo Neira Ayuso (2):
      netfilter: xt_CT: fix timeout setting with IPv6
      Merge branch 'master' of git://git.kernel.org/.../davem/net

Peter Korsgaard (1):
      NET_VENDOR_TI: make available for am33xx as well

Piotr Haber (1):
      bcma: fix unregistration of cores

Stanislav Yakovlev (1):
      net/wireless: ipw2200: Fix panic occurring in ipw_handle_promiscu=
ous_tx()

Stanislaw Gruszka (3):
      cfg80211/mac80211: avoid state mishmash on deauth
      mac80211: check if key has TKIP type before updating IV
      rt2x00: usb: fix reset resume

Steffen Klassert (1):
      ipv4: Fix flushing of cached routing informations

Stephane Grosjean (1):
      can: sja1000: fix/add miniPCIe/cPCI PC/104Plus PCI/104e PEAK-Syst=
em boards

Tilman Schmidt (1):
      bas_gigaset: fix pre_reset handling

Veaceslav Falico (4):
      pch_gbe: create functions for MAC_RX {en,dis}able
      pch_gbe: don't re-set RX_FIFO_ERR flag in napi_poll
      pch_gbe: don't reset MAC_RX on FIFO overflow
      pch_gbe: fix error handling in pch_gbe_up()

Vipul Pandya (1):
      cxgb4: Remove unnecessary #ifdef condition

Wei Yang (1):
      gianfar_ptp: use iomem, not ioports resource tree in probe

Wolfgang Grandegger (1):
      can: flexcan: disable bus error interrupts for the i.MX6q

Yuanhan Liu (1):
      brcmfmac: fix potential NULL dereference

Yuchung Cheng (1):
      tcp: add SYN/data info to TCP_INFO

 MAINTAINERS                                           |   8 ++-
 drivers/bcma/main.c                                   |   5 +-
 drivers/isdn/gigaset/bas-gigaset.c                    |  19 +++++--
 drivers/net/can/flexcan.c                             |  19 +++++--
 drivers/net/can/sja1000/peak_pci.c                    |  13 ++++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h            |  19 +++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c       |  29 ++--------
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h        |   3 ++
 drivers/net/ethernet/freescale/gianfar_ptp.c          |   2 +-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c            |   3 +-
 drivers/net/ethernet/mellanox/mlx4/eq.c               |  18 +++++--
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c  | 116 ++++++++++=
+++---------------------------
 drivers/net/ethernet/qlogic/qla3xxx.c                 |   9 +++-
 drivers/net/ethernet/ti/Kconfig                       |   2 +-
 drivers/net/ethernet/tile/tilegx.c                    |  35 ++++++----=
--
 drivers/net/phy/Kconfig                               |   5 ++
 drivers/net/phy/Makefile                              |   1 +
 drivers/net/phy/at803x.c                              | 176 ++++++++++=
+++++++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/usb/cdc_ether.c                           |  41 ++++++++--=
----
 drivers/net/usb/ipheth.c                              |   5 ++
 drivers/net/usb/qmi_wwan.c                            |  55 ++++++++++=
+++++++++
 drivers/net/usb/usbnet.c                              |   3 ++
 drivers/net/wireless/ath/ath9k/ar9003_2p2_initvals.h  | 164 ++++++++++=
++++++++++++++++++----------------------------
 drivers/net/wireless/ath/ath9k/hif_usb.c              |   1 +
 drivers/net/wireless/b43/main.c                       |   4 ++
 drivers/net/wireless/brcm80211/brcmfmac/usb.c         |   2 +-
 drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c |  70 +++++++++-=
--------------
 drivers/net/wireless/ipw2x00/ipw2200.c                |   2 +-
 drivers/net/wireless/iwlwifi/dvm/devices.c            |  39 ++++++++--=
----
 drivers/net/wireless/mwifiex/cfg80211.c               |   7 ++-
 drivers/net/wireless/mwifiex/scan.c                   |  13 ++---
 drivers/net/wireless/rt2x00/rt2500usb.c               |   1 +
 drivers/net/wireless/rt2x00/rt2800usb.c               |   1 +
 drivers/net/wireless/rt2x00/rt73usb.c                 |   1 +
 drivers/net/wireless/rtlwifi/usb.c                    |   2 +-
 drivers/vhost/net.c                                   |   3 +-
 include/linux/tcp.h                                   |   3 +-
 include/net/cfg80211.h                                |   1 +
 include/uapi/linux/tcp.h                              |   1 +
 net/8021q/vlan.c                                      |   4 +-
 net/batman-adv/bridge_loop_avoidance.c                |  27 ++++++----
 net/batman-adv/routing.c                              |   8 ++-
 net/batman-adv/types.h                                |   2 +
 net/bluetooth/smp.c                                   |   6 ++-
 net/core/skbuff.c                                     |   6 ++-
 net/ipv4/route.c                                      |   9 ++--
 net/ipv4/tcp.c                                        |  10 ++--
 net/ipv4/tcp_input.c                                  |  13 ++++-
 net/ipv4/tcp_ipv4.c                                   |   1 +
 net/ipv4/tcp_minisocks.c                              |   1 +
 net/ipv4/tcp_timer.c                                  |   4 +-
 net/ipv6/route.c                                      |   4 +-
 net/mac80211/iface.c                                  |   2 +-
 net/mac80211/mlme.c                                   |  35 +++++++---=
--
 net/mac80211/sta_info.c                               |   4 +-
 net/mac80211/util.c                                   |   4 +-
 net/mac80211/wpa.c                                    |  14 +++--
 net/netfilter/ipvs/ip_vs_ctl.c                        |   3 +-
 net/netfilter/xt_CT.c                                 |  10 ++--
 net/netfilter/xt_TEE.c                                |   1 +
 net/netfilter/xt_nat.c                                |   8 +--
 net/netlink/af_netlink.c                              |  19 +++++--
 net/wireless/mlme.c                                   |  12 ++---
 63 files changed, 724 insertions(+), 384 deletions(-)
 create mode 100644 drivers/net/phy/at803x.c
