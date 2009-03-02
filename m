From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Sun, 01 Mar 2009 21:40:39 -0800 (PST)
Message-ID: <20090301.214039.218300763.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41739
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751004AbZCBFk6 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2009 00:40:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) TCP retransmit accounting fix from Ilpo.

2) netconsole over devices configured with VLANs can crash,
   fix from Herbert Xu.

3) DRR scheduler crashes when TCA_OPTIONS are not specified.
   Fix from Jarek P.

4) VETH carrier detection fix from Eric Bierderman.

5) Several small driver fixes all over.

6) IPV6 fix with time-wait sockets when namespaces are enabled,
   from Pavel Emelyanov.

7) Fix hp-plus build, again, from Randy Dunlap.

Please pull, thanks a lot!

The following changes since commit 778ef1e6cbb049c9bcbf405936ee6f2b6e45=
1892:
  Linus Torvalds (1):
        Merge git://git.kernel.org/.../gregkh/staging-2.6

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Andrey Borzenkov (1):
      orinoco: do not resgister NULL pm_notifier function

Bj=F8rn Mork (2):
      cdc_ether: add usb id for Ericsson F3507g
      usbnet: make usbnet_get_link() fall back to ethtool_op_get_link()

Chris Leech (2):
      net headers: cleanup dcbnl.h
      net headers: export dcbnl.h

David S. Miller (5):
      Merge branch 'master' of /home/davem/src/GIT/linux-2.6/
      Merge branch 'master' of git://git.kernel.org/.../kaber/nf-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6
      Merge branch 'master' of /home/davem/src/GIT/linux-2.6/

Dhananjay Phadke (2):
      netxen: fix physical port mapping
      netxen: handle pci bar 0 mapping failure

Dmitriy Taychenachev (1):
      zaurus: add usb id for motomagx phones

Eric Leblond (3):
      netfilter: nf_conntrack_ipv6: fix nf_log_packet message in icmpv6=
 conntrack
      netfilter: nfnetlink_log: fix per-rule qthreshold override
      netfilter: nfnetlink_log: fix timeout handling

Eric W. Biederman (1):
      veth: Fix carrier detect

Greg Kroah-Hartman (1):
      asix: new device ids

Herbert Xu (1):
      netpoll: Add drop checks to all entry points

Ilpo J=E4rvinen (1):
      tcp: fix retrans_out leaks

Ivan Vecera (1):
      r8169: read MAC address from EEPROM on init (2nd attempt)

Jan Engelhardt (1):
      netfilter: make proc/net/ip* print names from foreign NFPROTO

Jarek Poplawski (1):
      pkt_sched: sch_drr: Fix oops in drr_change_class.

Joe Perches (1):
      tcp_scalable: Update malformed & dead url

Josef Drexler (1):
      netfilter: xt_recent: fix proc-file addition/removal of IPv4 addr=
esses

Kiran Divekar (1):
      libertas: fix misuse of netdev_priv() and dev->ml_priv

Larry Finger (1):
      rtl8187: New USB ID's for RTL8187L

Michael Buesch (2):
      b44: Unconditionally enable interrupt routing on reset
      b44: Disable device on shutdown

Patrick McHardy (2):
      Merge branch 'master' of /repos/git/net-2.6
      netfilter: nf_conntrack: don't try to deliver events for untracke=
d connections

Pavel Emelyanov (1):
      ipv6: don't use tw net when accounting for recycled tw

Randy Dunlap (1):
      net: fix hp-plus build error

Rini van Zetten (1):
      gianfar: Do right check on num_txbdfree

Vasanthakumar Thiagarajan (1):
      ath9k: Fix panic upon attach failure

 drivers/net/b44.c                              |   13 +-
 drivers/net/gianfar.c                          |    2 +-
 drivers/net/hp-plus.c                          |    2 +-
 drivers/net/netxen/netxen_nic_main.c           |   16 ++-
 drivers/net/r8169.c                            |  114 +++++++++++++-
 drivers/net/usb/asix.c                         |    8 +
 drivers/net/usb/cdc_ether.c                    |    5 +
 drivers/net/usb/usbnet.c                       |    4 +-
 drivers/net/usb/zaurus.c                       |    5 +
 drivers/net/veth.c                             |   51 ++-----
 drivers/net/wireless/ath9k/main.c              |   24 ++-
 drivers/net/wireless/libertas/ethtool.c        |   12 +-
 drivers/net/wireless/libertas/if_usb.c         |    4 +-
 drivers/net/wireless/libertas/main.c           |   31 ++--
 drivers/net/wireless/libertas/persistcfg.c     |   16 +-
 drivers/net/wireless/libertas/scan.c           |    4 +-
 drivers/net/wireless/libertas/tx.c             |    2 +-
 drivers/net/wireless/libertas/wext.c           |   72 +++++-----
 drivers/net/wireless/orinoco/orinoco.c         |   19 ++-
 drivers/net/wireless/rtl818x/rtl8187_dev.c     |   12 ++
 include/linux/Kbuild                           |    1 +
 include/linux/dcbnl.h                          |    4 +-
 include/linux/netfilter/xt_NFLOG.h             |    2 +-
 include/net/netfilter/nf_conntrack_core.h      |    2 +-
 net/8021q/vlan_core.c                          |   10 ++
 net/core/dev.c                                 |    6 +
 net/ipv4/tcp_input.c                           |    9 +-
 net/ipv4/tcp_scalable.c                        |    2 +-
 net/ipv6/inet6_hashtables.c                    |    4 +-
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |    5 +-
 net/netfilter/nfnetlink_log.c                  |    8 +-
 net/netfilter/x_tables.c                       |  199 ++++++++++++++++=
+-------
 net/netfilter/xt_recent.c                      |    2 +-
 net/sched/sch_drr.c                            |    6 +-
 34 files changed, 467 insertions(+), 209 deletions(-)
