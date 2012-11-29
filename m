From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 28 Nov 2012 21:47:32 -0500 (EST)
Message-ID: <20121128.214732.1634269294133625782.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Some more fixes trickled in over the past few days:

1) PIM device names can overflow the IFNAMSIZ buffer unless we
   properly limit the allowed indexes, fix from Eric Dumazet.

2) Under heavy load we can OOPS in icmp reply processing due to
   an unchecked inet_putpeer() call.  Fix from Neal Cardwell.

3) SCTP round trip calculations need to use 64-bit math to avoid
   overflows, fix from Schoch Christian.

4) Fix a memory leak and an error return flub in SCTP and IRDA
   triggerable by userspace.  Fix from Tommi Rantala and found by
   the syscall fuzzer (trinity).

5) MLX4 driver gives bogus size to memcpy() call, fix from Amir
   Vadai.

6) Fix length calculation in VHOST descriptor translation, from
   Michael S. Tsirkin.

7) Ambassador ATM driver loops forever while loading firmware, fix
   from Dan Carpenter.

8) Over MTU packets in openvswitch warn about wrong device, fix
   from Jesse Gross.

9) Netfilter IPSET's netlink code can overrun a string buffer
   because it's not properly limited to IFNAMSIZ.  Fix from
   Florian Westphal.

10) PCAN USB driver sets wrong timestamp in SKB, from Oliver
    Hartkopp.

11) Make sure the RX ifindex always has a valid value in the
    CAN BCM driver, even if we haven't received a frame yet.
    Fix also from Oliver Hartkopp.

Please pull, thanks a lot!

The following changes since commit 194d9831f0419b5125dc94ec0ece4434d8ef=
74f0:

  Merge tag 'sound-3.7' of git://git.kernel.org/pub/scm/linux/kernel/gi=
t/tiwai/sound (2012-11-24 08:32:11 -1000)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to a45085f6a7801f95cd5682290195224e268627fd=
:

  Merge branch 'fixes' of git://git.kernel.org/pub/scm/linux/kernel/git=
/jesse/openvswitch (2012-11-28 18:00:47 -0500)

----------------------------------------------------------------

Amir Vadai (1):
      net/mlx4_en: Can set maxrate only for TC0

Bj=F8rn Mork (1):
      net: qmi_wwan: add Huawei E173

Dan Carpenter (1):
      atm: forever loop loading ambassador firmware

David S. Miller (2):
      Merge branch 'master' of git://1984.lsi.us.es/nf
      Merge branch 'fixes' of git://git.kernel.org/.../jesse/openvswitc=
h

Eric Dumazet (1):
      net: ipmr: limit MRT_TABLE identifiers

=46lorian Westphal (1):
      netfilter: ipset: fix netiface set name overflow

Jesse Gross (1):
      openvswitch: Print device when warning about over MTU packets.

Jiri Pirko (1):
      team: fix hw_features setup

Mehak Mahajan (1):
      openvswitch: Store flow key len if ARP opcode is not request or r=
eply.

Michael S. Tsirkin (1):
      vhost: fix length for cross region descriptor

Neal Cardwell (1):
      ipv4: avoid passing NULL to inet_putpeer() in icmpv4_xrlim_allow(=
)

Oliver Hartkopp (2):
      can: peak_usb: fix hwtstamp assignment
      can: bcm: initialize ifindex for timeouts without previous frame =
reception

Schoch Christian (1):
      sctp: Error in calculation of RTTvar

Tommi Rantala (3):
      sctp: fix memory leak in sctp_datamsg_from_user() when copy from =
user space fails
      sctp: fix -ENOMEM result with invalid user space pointer in sendt=
o() syscall
      irda: irttp: fix memory leak in irttp_open_tsap() error path

 drivers/atm/ambassador.c                       |  1 +
 drivers/net/can/usb/peak_usb/pcan_usb.c        |  8 ++++++--
 drivers/net/can/usb/peak_usb/pcan_usb_pro.c    |  8 ++++++--
 drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c |  2 +-
 drivers/net/team/team.c                        |  4 +++-
 drivers/net/usb/qmi_wwan.c                     |  1 +
 drivers/vhost/vhost.c                          |  2 +-
 net/can/bcm.c                                  |  3 +++
 net/ipv4/icmp.c                                |  3 ++-
 net/ipv4/ipmr.c                                |  4 ++++
 net/irda/irttp.c                               |  1 +
 net/netfilter/ipset/ip_set_hash_netiface.c     |  2 +-
 net/openvswitch/flow.c                         | 14 +++++---------
 net/openvswitch/vport-netdev.c                 |  2 +-
 net/sctp/chunk.c                               | 20 ++++++++++++++----=
--
 net/sctp/socket.c                              |  4 ++--
 net/sctp/transport.c                           |  2 +-
 17 files changed, 53 insertions(+), 28 deletions(-)
