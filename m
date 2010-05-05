From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Wed, 05 May 2010 01:27:50 -0700 (PDT)
Message-ID: <20100505.012750.246538504.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Remove bogus Kconfig default and fix bug in new sierra_net driver.
   From Elina Pasheva.

2) Fix powerpc OOPSer in e1000e, from Anton Blanchard.

3) FEC miscalculates register address in MAC address changing, writing
   to random memory, oops.  Fix from Mattias Walstr=F6m.

4) p54pci doesn't use DMA API correctly, from Hans de Goede.

5) SOCK_DEBUG can miscompile, fix from Jan Engelhardt.

6) SCTP will skb_over_panic() when there are multiple parameter errors,=
 fix
   from Neil Horman.

7) r8169_rx_interrupt() explodes when called from reset workqueue, fix =
from
   Eric Dumazet.

8) PPP input deref's two bytes before checking there are actually 2 byt=
es
   there in the linear packet area, furthermore ppp_read() isn't equipp=
ed
   to handle non-linear skbs.  Both fixes from Simon Arlott.

9) dm9601 writes wrong bits in DM_SHARED_CTRL register, resulting in
   severe degradation of performance (in some cases ~900Kb/s to
   ~30Kb/s).  Fix from Peter Korsgaard.

10) Add new Micrel PHY device driver, from David J. Choi.

11) ep93xx driver ACKs RX ring at the wrong spot, hanging chip.  Fix
    from Stefan Agner.

12) Default multicast hops socket setting is wrong as per RFC 3493.
    It should be '1' rather than the per-route unicast hop metric.
    Based upon a report by Elliot Hughes.

Please pull, thanks a lot!

The following changes since commit d93ac51c7a129db7a1431d859a3ef45a0b1f=
3fc5:
  Linus Torvalds (1):
        Merge branch 'for-linus' of git://git.kernel.org/.../sage/ceph-=
client

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Anton Blanchard (1):
      e1000e: Fix oops caused by ASPM patch.

David J. Choi (1):
      drivers/net/phy: micrel phy driver

David S. Miller (3):
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6
      net: ep93xx_eth stops receiving packets
      ipv6: Fix default multicast hops setting.

Elina Pasheva (2):
      net/usb: remove default in Kconfig for sierra_net driver
      net/usb: initiate sync sequence in sierra_net.c driver

Eric Dumazet (1):
      r8169: Fix rtl8169_rx_interrupt()

Hans de Goede (1):
      p54pci: fix bugs in p54p_check_tx_ring

Jan Engelhardt (1):
      net: fix compile error due to double return type in SOCK_DEBUG

Mattias Walstr=F6m (1):
      FEC: Fix kernel panic in fec_set_mac_address.

Neil Horman (1):
      sctp: Fix skb_over_panic resulting from multiple invalid paramete=
r errors (CVE-2010-1173) (v4)

Peter Korsgaard (1):
      dm9601: fix phy/eeprom write routine

Sebastian Siewior (1):
      net/sb1250: register mdio bus in probe

Simon Arlott (2):
      ppp_generic: pull 2 bytes so that PPP_PROTO(skb) is valid
      ppp_generic: handle non-linear skbs when passing them to pppd

 drivers/net/arm/ep93xx_eth.c      |   10 ++--
 drivers/net/e1000e/netdev.c       |    3 +
 drivers/net/fec.c                 |    2 +-
 drivers/net/phy/Kconfig           |    5 ++
 drivers/net/phy/Makefile          |    1 +
 drivers/net/phy/micrel.c          |  104 +++++++++++++++++++++++++++++=
++++++++
 drivers/net/ppp_generic.c         |   34 ++++++++----
 drivers/net/r8169.c               |   22 ++++++--
 drivers/net/sb1250-mac.c          |   67 ++++++++++++------------
 drivers/net/usb/Kconfig           |    1 -
 drivers/net/usb/dm9601.c          |    2 +-
 drivers/net/usb/sierra_net.c      |    3 +
 drivers/net/wireless/p54/p54pci.c |    2 +-
 include/net/sctp/structs.h        |    1 +
 include/net/sock.h                |    2 +-
 net/ipv6/af_inet6.c               |    2 +-
 net/sctp/sm_make_chunk.c          |   62 ++++++++++++++++++++--
 17 files changed, 256 insertions(+), 67 deletions(-)
 create mode 100644 drivers/net/phy/micrel.c
