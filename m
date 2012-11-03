From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: pull request: batman-adv 2012-11-03
Date: Sat,  3 Nov 2012 19:48:25 +0100
Message-ID: <1351968514-12357-1-git-send-email-ordex@autistici.org>
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

here you have another patchset with two new features intended for
net-next/linux-3.8.

Patch 1/9 adds the new UNICAST_4ADDR packet type which contains both the =
source
and the destination node addresses (unlike the classic UNICAST which cont=
ains
the destination only) and can encapsulate different packet subtypes.

Then all the remaining patches introduce the new Distributed ARP Table (D=
AT)
component. It is the first user of the new packet type introduced by 1/9.

DAT is the results of Antonio Quartulli's Google Summer Of Code 2011.
It was already sent to netdev once in the past, but got rejected because =
of its
dependency on the ARP/neigh layer internals. In this new version a batman=
-adv
private ARP storage has been implemented, so dropping any possible relati=
onship
with the inner neigh code.

Please, let me know if there is any problem.

Thank you very much,
		Antonio



The following changes since commit b77bc2069d1e437d5a1a71bb5cfcf4556ee400=
15:

  ppp: make ppp_get_stats64 static (2012-11-01 12:38:31 -0400)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

for you to fetch changes up to f113f61fd0af6dfd08f8110236cd47c410b36711:

  batman-adv: Add get_ethtool_stats() support for DAT (2012-11-02 21:50:1=
5 +0100)

----------------------------------------------------------------
Included changes:
- new packet type called UNICAST_4ADDR: in this packet it is possible to =
find
  both source and destination node (in the classic UNICAST header only th=
e
  destination field exists).
- a new feature: Distributed ARP Table (D.A.T.). It aims to reduce ARP lo=
okups
  latency by means of a simil-DHT approach.

----------------------------------------------------------------
Antonio Quartulli (8):
      batman-adv: add UNICAST_4ADDR packet type
      batman-adv: Distributed ARP Table - add a new debug log level
      batman-adv: Distributed ARP Table - create DHT helper functions
      batman-adv: Distributed ARP Table - implement local storage
      batman-adv: Distributed ARP Table - add ARP parsing functions
      batman-adv: Distributed ARP Table - add snooping functions for ARP =
messages
      batman-adv: Distributed ARP Table - add compile option
      batman-adv: Distributed ARP Table - add runtime switch

Martin Hundeb=C3=B8ll (1):
      batman-adv: Add get_ethtool_stats() support for DAT

 Documentation/networking/batman-adv.txt |    3 +-
 net/batman-adv/Kconfig                  |   10 +
 net/batman-adv/Makefile                 |    1 +
 net/batman-adv/debugfs.c                |   20 +
 net/batman-adv/distributed-arp-table.c  | 1066 +++++++++++++++++++++++++=
++++++
 net/batman-adv/distributed-arp-table.h  |  167 +++++
 net/batman-adv/hard-interface.c         |    3 +
 net/batman-adv/main.c                   |    9 +
 net/batman-adv/main.h                   |   13 +-
 net/batman-adv/originator.c             |    2 +
 net/batman-adv/packet.h                 |   43 +-
 net/batman-adv/routing.c                |   41 +-
 net/batman-adv/send.c                   |    4 +
 net/batman-adv/soft-interface.c         |   28 +-
 net/batman-adv/sysfs.c                  |    7 +
 net/batman-adv/types.h                  |   73 +++
 net/batman-adv/unicast.c                |  134 +++-
 net/batman-adv/unicast.h                |   36 +-
 18 files changed, 1631 insertions(+), 29 deletions(-)
 create mode 100644 net/batman-adv/distributed-arp-table.c
 create mode 100644 net/batman-adv/distributed-arp-table.h
