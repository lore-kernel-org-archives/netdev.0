From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Thu, 12 Apr 2012 15:39:30 -0400 (EDT)
Message-ID: <20120412.153930.984522270356384384.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40715 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751672Ab2DLTjd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 15:39:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Fix bluetooth userland regression reported by Keith Packard,
   from Gustavo Padovan.

2) Revert ath9k PS idle change, from Sujith Manoharan.

3) Correct default TCP memory limits (again), from Eric
   Dumazet.

4) Fix tcp_rcv_rtt_update() accidental use of unscaled RTT, from
   Neal Cardwell.

5) We made a facility for layers like wireless to say how much
   tailroom they need in the SKB for link layer stuff such as
   wireless encryption etc., but TCP works hard to fill every SKB
   out to the end defeating this specification.

   This leads to every TCP packet getting reallocated by the wireless
   code in order to have the right amount of tailroom available.

   Fix TCP to only fill SKBs out to the real amount of data area it
   asked for during the allocation, this way it won't eat into the
   slack added for the device's tailroom needs.

   Reported by Marc Merlin and fixed by Eric Dumazet.

6) Leaks, endian bugs, and new device IDs in bluetooth from Santosh
   Nayak, Jo=E3o Paulo Rechi Vita, Cho, Yu-Chen, Andrei Emeltchenko,
   AceLan Kao, and Andrei Emeltchenko.

7) OOPS on tty_close fix in bluetooth's hci_ldisc from Johan Hovold.

8) netfilter erroneously scales TCP window twice, fix from Changli Gao.

9) Memleak fix in wext-core from Julia Lawall.

10) Consistently handle invalid TCP packets in ipv4 vs. ipv6 conntrack,
    from Jozsef Kadlecsik.

11) Validate IP header length properly in netfilter conntrack's
    ipv4_get_l4proto().

Please pull, thanks a lot!

The following changes since commit f68e556e23d1a4176b563bcb25d8baf2c531=
3f91:

  Make the "word-at-a-time" helper functions more commonly usable (2012=
-04-06 13:54:56 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to 5d949944229b0a08e218723be231731cd86b94f3=
:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/gi=
t/linville/wireless into for-davem (2012-04-12 09:55:22 -0400)

----------------------------------------------------------------

AceLan Kao (1):
      Bluetooth: Add support for Atheros [04ca:3005]

Andrei Emeltchenko (3):
      Bluetooth: Fix memory leaks due to chan refcnt
      Bluetooth: mgmt: Add missing endian conversion
      Bluetooth: mgmt: Fix timeout type

Brian Gix (1):
      Bluetooth: mgmt: Fix corruption of device_connected pkt

Changli Gao (1):
      netfilter: nf_ct_tcp: don't scale the size of the window up twice

Chen, Chien-Chia (1):
      rt2x00: Fix rfkill_polling register function.

Cho, Yu-Chen (1):
      Bluetooth: Add Atheros maryann PIDVID support

David S. Miller (2):
      Merge branch 'master' of git://1984.lsi.us.es/net
      MAINTAINERS: Mark NATSEMI driver as orphan'd.

Don Zickus (1):
      Bluetooth: btusb: typo in Broadcom SoftSailing id

Eric Dumazet (3):
      tcp: restore correct limit
      net: allow pskb_expand_head() to get maximum tailroom
      tcp: avoid order-1 allocations on wifi and tx path

Gao feng (1):
      netfilter: nf_conntrack: fix incorrect logic in nf_conntrack_init=
_net

Gustavo Padovan (1):
      Bluetooth: Fix userspace compatibility issue with mgmt interface

Hemant Gupta (1):
      Bluetooth: Use correct flags for checking HCI_SSP_ENABLED bit

Herbert Xu (1):
      bridge: Do not send queries on multicast group leaves

Johan Hedberg (2):
      Bluetooth: Don't increment twice in eir_has_data_type()
      Bluetooth: Check for minimum data length in eir_has_data_type()

Johan Hovold (2):
      Bluetooth: hci_ldisc: fix NULL-pointer dereference on tty_close
      Bluetooth: hci_core: fix NULL-pointer dereference at unregister

Johannes Berg (2):
      mac80211: fix association beacon wait timeout
      nl80211: ensure interface is up in various APIs

John W. Linville (2):
      Merge branch 'master' of git://git.kernel.org/.../bluetooth/bluet=
ooth
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem

Jozsef Kadlecsik (2):
      netfilter: nf_ct_ipv4: handle invalid IPv4 and IPv6 packets consi=
stently
      netfilter: nf_ct_ipv4: packets with wrong ihl are invalid

Jo=E3o Paulo Rechi Vita (1):
      Bluetooth: btusb: Add USB device ID "0a5c 21e8"

Julia Lawall (1):
      net/wireless/wext-core.c: add missing kfree

Larry Finger (5):
      rtlwifi: rtl8192de: Fix firmware initialization
      mac80211: Convert WARN_ON to WARN_ON_ONCE
      rtlwifi: Fix oops on rate-control failure
      rtlwifi: Preallocate USB read buffers and eliminate kalloc in rea=
d routine
      rtlwifi: Add missing DMA buffer unmapping for PCI drivers

Marcel Holtmann (1):
      MAINTAINERS: update Bluetooth tree locations

Neal Cardwell (1):
      tcp: fix tcp_rcv_rtt_update() use of an unscaled RTT sample

Pablo Neira Ayuso (1):
      netfilter: ip6_tables: ip6t_ext_hdr is now static inline

Paul Gortmaker (1):
      bcma: fix build error on MIPS; implicit pcibios_enable_device

Samuel Ortiz (1):
      NFC: Fix the LLCP Tx fragmentation loop

Santosh Nayak (1):
      Bluetooth: Fix Endian Bug.

Sujith Manoharan (1):
      Revert "ath9k: fix going to full-sleep on PS idle"

 MAINTAINERS                                    |   11 ++++---
 drivers/bcma/Kconfig                           |    2 +-
 drivers/bcma/driver_pci_host.c                 |    1 +
 drivers/bluetooth/ath3k.c                      |    4 +++
 drivers/bluetooth/btusb.c                      |    5 +++-
 drivers/bluetooth/hci_ldisc.c                  |    2 +-
 drivers/net/wireless/ath/ath9k/main.c          |    8 ++----
 drivers/net/wireless/rt2x00/rt2x00dev.c        |    6 +---
 drivers/net/wireless/rtlwifi/base.c            |    5 +++-
 drivers/net/wireless/rtlwifi/pci.c             |    7 ++++-
 drivers/net/wireless/rtlwifi/rtl8192de/sw.c    |    6 ----
 drivers/net/wireless/rtlwifi/usb.c             |   34 +++++++++++-----=
------
 drivers/net/wireless/rtlwifi/wifi.h            |    6 +++-
 include/linux/netfilter_ipv6/ip6_tables.h      |   12 +++++++-
 include/linux/skbuff.h                         |   13 +++++++++
 include/net/bluetooth/hci.h                    |    3 +-
 include/net/bluetooth/hci_core.h               |   12 ++++----
 include/net/bluetooth/mgmt.h                   |    2 +-
 include/net/mac80211.h                         |    2 +-
 net/bluetooth/hci_core.c                       |    7 +++++
 net/bluetooth/l2cap_core.c                     |    3 ++
 net/bluetooth/l2cap_sock.c                     |    5 ++--
 net/bluetooth/mgmt.c                           |   13 ++++++---
 net/bridge/br_multicast.c                      |   81 ----------------=
------------------------------------
 net/bridge/br_private.h                        |    4 ---
 net/core/skbuff.c                              |    4 ++-
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |   12 ++++++--
 net/ipv4/tcp.c                                 |   11 ++++---
 net/ipv4/tcp_input.c                           |    7 +++--
 net/ipv4/tcp_output.c                          |    2 +-
 net/ipv6/netfilter/ip6_tables.c                |   14 ---------
 net/mac80211/mlme.c                            |    3 +-
 net/netfilter/nf_conntrack_core.c              |    2 +-
 net/netfilter/nf_conntrack_proto_tcp.c         |    4 +--
 net/nfc/llcp/commands.c                        |    4 +--
 net/wireless/nl80211.c                         |   31 +++++++++++-----=
----
 net/wireless/wext-core.c                       |    6 ++--
 37 files changed, 160 insertions(+), 194 deletions(-)
