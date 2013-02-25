From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Mon, 25 Feb 2013 16:09:53 -0500 (EST)
Message-ID: <20130225.160953.1367227466581103223.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


There's a small merge that will happen for drivers/net/Kconfig, but
GIT automerges it just fine.

1) ping_err() ICMP error handler looks at wrong ICMP header, from
   Li Wei.

2) TCP socket hash function on ipv6 is too weak, from Eric Dumazet.

3) netif_set_xps_queue() forgets to drop mutex on errors, fix from
   Alexander Duyck.

4) sum_frag_mem_limit() can deadlock due to lack of BH disabling,
   fix from Eric Dumazet.

5) TCP SYN data is miscalculated in tcp_send_syn_data(), because
   the amount of TCP option space was not taken into account
   properly in this code path.  Fix from yuchung Cheng.

6) MLX4 driver allocates device queues with the wrong size, from
   Kleber Sacilotto.

7) sock_diag can access past the end of the sock_diag_handlers[] array,
   from Mathias Krause.

8) vlan_set_encap_proto() makes incorrect assumptions about where
   skb->data points, rework the logic so that it works regardless
   of where skb->data happens to be.  From Jesse Gross.

9) Fix gianfar build failure with NET_POLL enabled, from Paul
   Gortmaker.

10) Fix Ipv4 ID setting and checksum calculations in GRE driver,
    from Pravin B Shelar.

11) bgmac driver does:

	int i;

	for (i =3D 0; ...; ...) {
		...
		for (i =3D 0; ...; ...) {

    effectively corrupting the outer loop index, use a seperate
    variable for the inner loops.  From Rafa=A9=A9 Mi=A9=A9ecki.

12) Fix suspend bugs in smsc95xx driver, from Ming Lei.

Please pull, thanks a lot!

The following changes since commit a0b1c42951dd06ec83cc1bc2c9788131d9fe=
fcd8:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next (2=
013-02-20 18:58:50 -0800)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net master

for you to fetch changes up to eb970ff07c15f13eb474f643fd165ebe3e4e24b2=
:

  usbnet: smsc95xx: rename FEATURE_AUTOSUSPEND (2013-02-25 15:49:52 -05=
00)

----------------------------------------------------------------
Alexander Duyck (1):
      net: Fix locking bug in netif_set_xps_queue

Avinash Patil (1):
      mwifiex: fix system freeze while reloading driver

Cong Wang (1):
      vlan: adjust vlan_set_encap_proto() for its callers

Daniel Drake (1):
      mwifiex: don't drop carrier flag over suspend

David S. Miller (1):
      Merge branch 'wireless'

Eric Dumazet (2):
      ipv6: use a stronger hash for tcp
      net: fix possible deadlock in sum_frag_mem_limit

=46abio Estevam (2):
      net: fec: Ensure that initialization is done prior to request_irq=
()
      net: fec: Fix division by zero

Jitendra Kalsaria (1):
      qlcnic: Bump up the version to 5.1.35

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem

Kees Cook (1):
      vxlan: remove depends on CONFIG_EXPERIMENTAL

Kleber Sacilotto de Souza (2):
      mlx4_en: fix allocation of device tx_cq
      mlx4_en: fix allocation of CPU affinity reverse-map

Larry Finger (1):
      b43: Fix lockdep splat on module unload

Li Wei (2):
      ipv4: fix a bug in ping_err().
      ipv4: fix error handling in icmp_protocol.

Manish Chopra (1):
      qlcnic: Fix configure interrupts for 83xx adapter types

Mathias Krause (2):
      sock_diag: Fix out-of-bounds access to sock_diag_handlers[]
      sock_diag: Simplify sock_diag_handlers[] handling in __sock_diag_=
rcv_msg

Ming Lei (3):
      usbnet: smsc95xx: fix suspend failure
      usbnet: smsc95xx: fix broken runtime suspend
      usbnet: smsc95xx: rename FEATURE_AUTOSUSPEND

Neil Horman (1):
      vmxnet3: fix ethtool ring buffer size setting

Paul Gortmaker (1):
      gianfar: fix compile fail for NET_POLL=3Dy due to struct packing

Pravin B Shelar (4):
      IP_GRE: Fix IP-Identification.
      VXLAN: Use tunnel_ip_select_ident() for tunnel IP-Identification.
      IP_GRE: Fix GRE_CSUM case.
      Revert "ip_gre: propogate target device GSO capability to the tun=
nel device"

Rafa=A9=A9 Mi=A9=A9ecki (1):
      bgmac: fix indexing of 2nd level loops

Shahed Shaikh (1):
      qlcnic: Fix internal loopback test for 82xx adapter

Syam Sidhardhan (1):
      net/pasemi: Fix missing coding style

Wei Yongjun (1):
      brcmfmac: fix missing unlock on error in brcmf_notify_vif_event()

Yuchung Cheng (1):
      tcp: fix SYN-data space mis-accounting

stephen hemminger (3):
      sock: only define socket limit if mem cgroup configured
      bnx2x: remove dead code and make local funcs static
      vmxnet3: make local function static

 drivers/net/Kconfig                                   |  2 +-
 drivers/net/ethernet/broadcom/bgmac.c                 | 18 +++++++++--=
-----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c      | 58 -----------=
-----------------------------------------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c      |  4 ++--
 drivers/net/ethernet/freescale/fec.c                  | 58 +++++++++++=
+++++++++++++++--------------------------
 drivers/net/ethernet/freescale/gianfar.c              | 26 +++++++++++=
+-----------
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c        |  4 ++--
 drivers/net/ethernet/pasemi/pasemi_mac.c              |  9 +++++---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h           |  6 +++---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c |  7 -------
 drivers/net/usb/smsc95xx.c                            | 36 +++++++++++=
++++-----------------
 drivers/net/vmxnet3/vmxnet3_drv.c                     |  4 ++--
 drivers/net/vmxnet3/vmxnet3_ethtool.c                 |  6 ++----
 drivers/net/vxlan.c                                   |  3 ++-
 drivers/net/wireless/b43/main.c                       |  3 ++-
 drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c |  4 +++-
 drivers/net/wireless/mwifiex/pcie.c                   | 21 ++---------=
--------
 drivers/net/wireless/mwifiex/sdio.c                   |  9 --------
 include/linux/if_vlan.h                               |  6 +++---
 include/net/icmp.h                                    |  1 +
 include/net/inet6_hashtables.h                        |  8 ++++----
 include/net/inet_frag.h                               |  8 +++++++-
 include/net/inet_sock.h                               |  1 +
 include/net/ipip.h                                    | 17 +++++++++++=
++++
 include/net/ipv6.h                                    | 12 +++++++++++
 net/core/dev.c                                        |  4 +++-
 net/core/sock.c                                       |  2 ++
 net/core/sock_diag.c                                  | 27 +++++++++--=
-------------
 net/ipv4/af_inet.c                                    | 17 ++++++++++-=
----
 net/ipv4/icmp.c                                       | 23 +++++++++++=
++++++++++
 net/ipv4/ip_gre.c                                     | 25 +++++++++++=
-----------
 net/ipv4/ping.c                                       |  4 ++--
 net/ipv4/tcp_output.c                                 | 18 +++++++++--=
-----
 33 files changed, 218 insertions(+), 233 deletions(-)
