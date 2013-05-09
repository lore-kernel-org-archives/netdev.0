From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: pull request net: batman-adv 2013-05-09
Date: Thu,  9 May 2013 12:56:43 +0200
Message-ID: <1368097007-817-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
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

here you have four fixes intended for net.

1/4 fixes the parsing of a string sent from userspace in order to avoid random
memory access in case of string length of 0.

2/4 adds a check for the return value of pskb_trim_rcsum() in order to stop
processing the skb in case of failure.

3/4 prevents DAT (the Distributed ARP Table) to send cached ARP replies when
both the source and the destination of the snooped ARP request are local clients
(meaning: directly connected to the node). This can confuse a bridge where
batman-adv is enslaved.

4/4 fix a race condition in the main clean up procedure by reordering
sub-components freeing function invocations.


Please pull or let me know if there is any problem.

Thanks a lot,
	Antonio


The following changes since commit 4f924b2aa4d3cb30f07e57d6b608838edcbc0d88:

  if_cablemodem.h: Add parenthesis around ioctl macros (2013-05-08 13:13:30 -0700)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-fix-for-davem

for you to fetch changes up to a4361860351e87876aebd9595906d928ce8572c6:

  batman-adv: reorder clean up routine in order to avoid race conditions (2013-05-09 12:39:45 +0200)

----------------------------------------------------------------
Included changes:
- fix parsing of user typed protocol string to avoid random memory access in
  some cases
- check pskb_trim_rcsum() return value
- prevent DAT from sending ARP replies when not needed
- reorder the main clean up routine to prevent race conditions

----------------------------------------------------------------
Antonio Quartulli (2):
      batman-adv: make DAT drop ARP requests targeting local clients
      batman-adv: reorder clean up routine in order to avoid race conditions

Marek Lindner (2):
      batman-adv: check proto length before accessing proto string buffer
      batman-adv: check return value of pskb_trim_rcsum()

 net/batman-adv/distributed-arp-table.c | 13 +++++++++++++
 net/batman-adv/main.c                  | 18 +++++++++++++-----
 net/batman-adv/network-coding.c        |  8 ++++++--
 3 files changed, 32 insertions(+), 7 deletions(-)
