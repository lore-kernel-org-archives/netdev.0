From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: pull request: batman-adv 2012-10-18
Date: Thu, 18 Oct 2012 21:24:53 +0200
Message-ID: <1350588295-22587-1-git-send-email-ordex@autistici.org>
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

here are two fixes intended for net. The first one fixes the CRC computat=
ion
used to check for broadcast packet duplicates. The wrong result lead to m=
any
(more than 80%) broadcast packets being dropped and so making the network=
 very
slow and mostly unusable. Think about all the ARP or DHCP requests not go=
ing
through.

The second patch fixes a potential race condition, still in the same dupl=
icated
broadcast check procedure, which can lead to wrong outcomes under certain
circumstances.

I would also like to enqueue patch 1/2 for sending to stable-{3.5/3.6}.

Thanks a lot,
	Antonio




The following changes since commit 43c422eda99b894f18d1cca17bcd2401efaf7b=
d0:

  apparmor: fix apparmor OOPS in audit_log_untrustedstring+0x1c/0x40 (201=
2-10-17 16:29:46 -0700)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-fix-for-davem

for you to fetch changes up to 7dac7b76b8db87fc79857a53a09730fb2148579b:

  batman-adv: Fix potential broadcast BLA-duplicate-check race condition =
(2012-10-18 18:17:31 +0200)

----------------------------------------------------------------
Included fixes:
- Fix broadcast packet CRC calculation which can lead to ~80% broadcast p=
acket
  loss
- Fix a race condition in duplicate broadcast packet check

----------------------------------------------------------------
Linus L=C3=BCssing (2):
      batman-adv: Fix broadcast packet CRC calculation
      batman-adv: Fix potential broadcast BLA-duplicate-check race condit=
ion

 net/batman-adv/bridge_loop_avoidance.c | 27 ++++++++++++++++++---------
 net/batman-adv/routing.c               |  8 +++++++-
 net/batman-adv/types.h                 |  2 ++
 3 files changed, 27 insertions(+), 10 deletions(-)
