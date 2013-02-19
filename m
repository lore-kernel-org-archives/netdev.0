From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2013-02-19
Date: Tue, 19 Feb 2013 17:04:58 -0500
Message-ID: <20130219220457.GA2126@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="82I3+IH0IqGh5yIs"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:35253 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933538Ab3BSWPK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 17:15:10 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--82I3+IH0IqGh5yIs
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

One last batch of stragglers intended for 3.9...

For the iwlwifi pull, Johannes says:

"I hadn't expected to ask you to pull iwlwifi-next again, but I have a
number of fixes most of which I'd also send in after rc1, so here it is.

The first commit is a merge error between mac80211-next and
iwlwifi-next; in addition I have fixes for P2P scanning and MVM driver
MAC (virtual interface) management from Ilan, a CT-kill (critical
temperature) fix from Eytan, and myself fixed three different little but
annoying bugs in the MVM driver.

The only ones I might not send for -rc1 are Emmanuel's debug patch, but
OTOH it should help greatly if there are any issues, and my own time
event debugging patch that I used to find the race condition but we
decided to keep it for the future."

For the mac80211 pull, Johannes says:

"Like iwlwifi-next, this would almost be suitable for rc1.

I have a fix for station management on non-TDLS drivers, a CAB queue
crash fix for mesh, a fix for an annoying (but harmless) warning, a
tracing fix and a documentation fix. Other than that, only a few mesh
cleanups."

Along with that is a fix for memory corruption in rtlwifi, an
orinoco_usb fix to avoid allocating a DMA buffer on the stack, an a
hostap fix to return -ENOMEM instead of -1 after a memory allocation
failure.  The remaining bits implement 802.11ac support for the mwifiex
driver -- I think that is still worth getting into 3.9.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 303c07db487be59ae9fda10600ea65ca11c21497:

  ppp: set qdisc_tx_busylock to avoid LOCKDEP splat (2013-02-19 14:33:55 -0=
500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

for you to fetch changes up to 0b7164458fc184455239ea3676af1b362df1ce1d:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless-next into for-davem (2013-02-19 14:56:34 -0500)

----------------------------------------------------------------

Avinash Patil (1):
      mwifiex: fix empty TX ring check for PCIe8897 while unloading driver

Bob Copeland (1):
      mac80211: enable vif.cab_queue for mesh

Emmanuel Grumbach (1):
      iwlwifi: dvm: improve (again) the prints in reclaim path

Eytan Lifshitz (1):
      iwlwifi: dvm: fix delayed enter to CT-kill bug

Ilan Peer (3):
      iwlwifi: mvm: Set the scan type according to the vif type
      iwlwifi: mvm: Fix resource allocation for P2P Device
      iwlwifi: mvm: Reserve MAC id 0 for managed interfaces

Johannes Berg (10):
      mac80211: clean up mesh code
      cfg80211: add correct docbook entries
      mac80211: fix harmless station flush warning
      cfg80211: fix station change if TDLS isn't supported
      Merge remote-tracking branch 'wireless-next/master' into iwlwifi-next
      iwlwifi: mvm: fix merge error
      iwlwifi: mvm: program DTIM timings properly
      iwlwifi: mvm: fix GO powersave client manipulation
      iwlwifi: mvm: add debug statement to time event add
      iwlwifi: mvm: fix time event command handling race

John W. Linville (2):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211-ne=
xt
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Jussi Kivilinna (1):
      rtlwifi: usb: allocate URB control message setup_packet and data buff=
er separately

Kumar Amit Mehta (2):
      net: wireless: orinoco: orinoco_usb.c: fix DMA buffers on stack
      net: wireless: hostap: hostap_ap.c: Return -ENOMEM instead of -1 for =
if kmalloc() fails.

Seth Forshee (1):
      mac80211: Fix incorrect use of STA_PR_FMT in trace points

Thomas Pedersen (3):
      mac80211: clean up mesh HT operation
      mac80211: stringify mesh peering events
      mac80211: don't spam mesh probe response messages

Yogesh Ashok Powar (2):
      mwifiex: coding style cleanup in bss parameter update
      mwifiex: add 802.11AC support

 Documentation/DocBook/80211.tmpl              |   4 +-
 drivers/net/wireless/hostap/hostap_ap.c       |   2 +-
 drivers/net/wireless/iwlwifi/dvm/commands.h   |   1 +
 drivers/net/wireless/iwlwifi/dvm/tt.c         |   2 +-
 drivers/net/wireless/iwlwifi/dvm/tx.c         |  51 +++--
 drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c   |  47 ++++-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c   |  10 +-
 drivers/net/wireless/iwlwifi/mvm/rx.c         |   1 +
 drivers/net/wireless/iwlwifi/mvm/scan.c       |   7 +-
 drivers/net/wireless/iwlwifi/mvm/sta.c        |  14 +-
 drivers/net/wireless/iwlwifi/mvm/sta.h        |   6 +-
 drivers/net/wireless/iwlwifi/mvm/time-event.c |  10 +-
 drivers/net/wireless/mwifiex/11ac.c           | 261 ++++++++++++++++++++++=
++++
 drivers/net/wireless/mwifiex/11ac.h           |  26 +++
 drivers/net/wireless/mwifiex/11n.c            |   7 +-
 drivers/net/wireless/mwifiex/11n.h            |   4 +-
 drivers/net/wireless/mwifiex/Makefile         |   1 +
 drivers/net/wireless/mwifiex/cfg80211.c       | 177 ++++++++++++++---
 drivers/net/wireless/mwifiex/cfp.c            | 159 +++++++++++++++-
 drivers/net/wireless/mwifiex/cmdevt.c         |  19 ++
 drivers/net/wireless/mwifiex/fw.h             | 127 ++++++++++++-
 drivers/net/wireless/mwifiex/ioctl.h          |   4 +
 drivers/net/wireless/mwifiex/join.c           |   8 +
 drivers/net/wireless/mwifiex/main.h           |  23 ++-
 drivers/net/wireless/mwifiex/pcie.c           |   5 +-
 drivers/net/wireless/mwifiex/scan.c           |  63 ++++++-
 drivers/net/wireless/mwifiex/sta_cmd.c        |   2 +-
 drivers/net/wireless/mwifiex/sta_cmdresp.c    |   1 +
 drivers/net/wireless/mwifiex/sta_ioctl.c      |   5 +-
 drivers/net/wireless/orinoco/orinoco_usb.c    |  11 +-
 drivers/net/wireless/rtlwifi/usb.c            |  44 +++--
 net/mac80211/cfg.c                            |  14 +-
 net/mac80211/iface.c                          |   8 +-
 net/mac80211/main.c                           |   3 +-
 net/mac80211/mesh.c                           | 116 ++++++------
 net/mac80211/mesh.h                           | 105 +++++------
 net/mac80211/mesh_hwmp.c                      |  68 +++----
 net/mac80211/mesh_pathtbl.c                   |  89 ++++-----
 net/mac80211/mesh_plink.c                     | 134 ++++++-------
 net/mac80211/mesh_sync.c                      |  47 ++---
 net/mac80211/rx.c                             |  12 +-
 net/mac80211/sta_info.h                       |   2 -
 net/mac80211/trace.h                          |   6 +-
 net/mac80211/tx.c                             |  26 ++-
 net/wireless/nl80211.c                        |   9 -
 45 files changed, 1297 insertions(+), 444 deletions(-)
 create mode 100644 drivers/net/wireless/mwifiex/11ac.c
 create mode 100644 drivers/net/wireless/mwifiex/11ac.h

--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--82I3+IH0IqGh5yIs
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAEBAgAGBQJRI/cJAAoJEJctW/TcYTgGsQwP/1nEYx66vu0S3uVhz7qleSp7
8N9DH/zsKBLXlgJbALLlZYLisfJVKtmaXva/PvxqsH23+xk7NkkgOefg4NiRxLDn
Lo1w2xiD6EPFdZhas+vDe7eVbTTG+Blg0pVEZ7pyNaQ4e+ZEsx9lBztFiVayCASD
19Vg/ko+Cv6b+RliZhIwLmuIhtuV8kYVKlVKRH7Vt0ygWwMPwuXemMs8LH16x13G
Vyq+j1vTnmqLifN6dqyd5s8ya+jtQQ3NENvBSdeWJITZfkiQ1gQng7ELLrVFK0Ln
+fx+Nxc6r7UbtKpfxDtE3d8zNwoukosati58TeYeXMfo7uZ550jKzd9RfTqvE+V9
8N6wzfiGUrF/sZyjz1IHfOTQ0PqWihgGejYLmYrBqEgd0wzo9GCFoq1z/A/MHonU
d3uHe9ecP48CbQhGIeo3EtSj6XZbnwq5l8lwxfOKsqlg2XMS1hRSdOcR9k8u179B
I1ddX50qX7T7kUD/Tv1hHC4RSgjY2UUmqZdZAmtM9ShmY37qhV8PXrvojEvE2uZ2
HP4yFuBN6uqr9361oCPiVeJ0L8jNp9fRUHisZBXREK8ucWLTZ0EJ39PeAqHC878v
HxJHp2RVowYU7sBww2wwpDyhxLwy46UAMe7GCI3ANZQeCSIUClx0swVir1S26Ze+
cA6KAUN7dknM8sbQ+6wq
=/vqE
-----END PGP SIGNATURE-----

--82I3+IH0IqGh5yIs--
