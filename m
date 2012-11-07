From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: pull request: batman-adv 2012-11-07
Date: Wed,  7 Nov 2012 20:11:30 +0100
Message-ID: <1352315502-20324-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

Hello David,

first of all thank you for having made us aware of the packet format prob=
lem in
batman-adv! The impact of __packed on performances was not entirely known=
 to me,
in particular for what concerns the RISC arch.

We have to change a number of packet formats before we can remove __packe=
d
everywhere which will obviously break compatibility.

However we already scheduled a compatibility break because we want to
heavily improve our packet formats and to provide a more flexible framewo=
rk that
would allow us to add new types and features while reducing the probabili=
ty of
breaking compatibility again and again as happened in the past (we are
implementing TypeLengthValue (TLV) containers among other things).

To avoid breaking compatibility (at least) twice we decided to fix now (i=
n this
patchset) what is fixable with no consequences to compatibility while we =
would
ilike to defer the remaining changes for the scheduled compatibility brea=
k.

In this patchset you have the two new features intended for net-next/linu=
x-3.8:
1) the new UNICAST_4ADDR packet type
2) the Distributed ARP Table (DAT) component

The new packet type has been reviewed to entirely address the alignment i=
ssue.
At the same time we also reviewed the other packet types but as I told yo=
u
before, we will send these changes later.

Other than that you have patch 02/12 that removes the __packed attribute =
from
the structures where it was not really needed.

Please, let me know if there is any problem.

Thank you very much,
		Antonio



The following changes since commit 6f0a0986e328dd61610d898a09c9f4aa960ae6=
4a:

  usbnet: runtime wake up device before calling usbnet_{read|write}_cmd (=
2012-11-07 03:53:38 -0500)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

for you to fetch changes up to 9affec6be810d1d529cb9dc95126119451696ba6:

  batman-adv: enable fast client detection using unicast_4addr packets (2=
012-11-07 20:00:24 +0100)

----------------------------------------------------------------
Included changes:
- minimal fixes to the packet layout to avoid the __packed attribute when=
 not
  needed
- new packet type called UNICAST_4ADDR: in this packet it is possible to =
find
  both source and destination node (in the classic UNICAST header only th=
e
  destination field exists).
- a new feature: Distributed ARP Table (D.A.T.). It aims to reduce ARP lo=
okups
  latency by means of a simil-DHT approach.

----------------------------------------------------------------
Antonio Quartulli (9):
      batman-adv: add UNICAST_4ADDR packet type
      batman-adv: Distributed ARP Table - add a new debug log level
      batman-adv: Distributed ARP Table - create DHT helper functions
      batman-adv: Distributed ARP Table - implement local storage
      batman-adv: Distributed ARP Table - add ARP parsing functions
      batman-adv: Distributed ARP Table - add snooping functions for ARP =
messages
      batman-adv: Distributed ARP Table - add compile option
      batman-adv: Distributed ARP Table - add runtime switch
      batman-adv: enable fast client detection using unicast_4addr packet=
s

Martin Hundeb=C3=B8ll (1):
      batman-adv: Add get_ethtool_stats() support for DAT

Sven Eckelmann (2):
      batman-adv: Reserve extra bytes in skb for better alignment
      batman-adv: Mark correctly aligned headers not as __packed

 Documentation/networking/batman-adv.txt |    3 +-
 net/batman-adv/Kconfig                  |   10 +
 net/batman-adv/Makefile                 |    1 +
 net/batman-adv/bat_iv_ogm.c             |    8 +-
 net/batman-adv/debugfs.c                |   20 +
 net/batman-adv/distributed-arp-table.c  | 1066 +++++++++++++++++++++++++=
++++++
 net/batman-adv/distributed-arp-table.h  |  167 +++++
 net/batman-adv/hard-interface.c         |    3 +
 net/batman-adv/icmp_socket.c            |    4 +-
 net/batman-adv/main.c                   |    9 +
 net/batman-adv/main.h                   |   13 +-
 net/batman-adv/originator.c             |    2 +
 net/batman-adv/packet.h                 |   68 +-
 net/batman-adv/routing.c                |   51 +-
 net/batman-adv/send.c                   |    4 +
 net/batman-adv/soft-interface.c         |   28 +-
 net/batman-adv/sysfs.c                  |    7 +
 net/batman-adv/translation-table.c      |   20 +-
 net/batman-adv/types.h                  |   73 +++
 net/batman-adv/unicast.c                |  135 +++-
 net/batman-adv/unicast.h                |   36 +-
 net/batman-adv/vis.c                    |    9 +-
 22 files changed, 1682 insertions(+), 55 deletions(-)
 create mode 100644 net/batman-adv/distributed-arp-table.c
 create mode 100644 net/batman-adv/distributed-arp-table.h
