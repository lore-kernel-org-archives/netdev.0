From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: [PATCH net-next 0/2] Small Modifications to GSO to allow
	segmentation of MPLS (repost)
Date: Tue, 23 Apr 2013 11:19:14 +0900
Message-ID: <1366683556-4956-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	=?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Joseph Gasparakis <joseph.gasparakis-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

[ Reposting with net-next in subject prefix,
  sorry for forgetting that the first time around ]

This series consists of two small (at least in terms of numbers of lines
of code changes) that allow support of GSO of non-MPLS GSO skbs that
are changed into MPLS GSO skbs via Open vSwtich and its push MPLS action.

A description of each of the two changes is provided in the changelog
of the two patches that comprise this series.

GSO of MPLS skbs may be achieved by (Open vSwtich) setting the following:

1. skb's mac_header should point to the beginning of the L2 header
   (no surprise!)
2. skb's mac_len should be the length of the L2 header plus
   the length of the MPLS stack. In other words, the MPLS stack
   is considered to be part of the l2 header.
3. skb's natwork_header should be set to just after the end of
   the MPLS stack. Or in other words the begining of the L3 header.
   This is consistent with 2.
4. skb's protocol should be left as the skb's original (non-MPLS) protocol.
   This is used by GSO to determine which callback to use to segment
   the (MPLS encapsulated) skb data.
5. The protocol in the skb's mac header should be set to the new
   (MPLS) protocol. This is what will appear on the wire.
6. skb's encapsulation_features should be set.
   This is introduced and explained in more detail in the first patch of the
   series.

I have posted a patch, "[PATCH v2.26] datapath: Add basic MPLS support to
kernel" which adds MPLS support to the kernel datapath of Open vSwtich.
That patch sets the above requirements and was used to exercise the MPLS
GSO code. The datapath patch is against the Open vSwtich tree but it is
intended that it be added to the Open vSwtich code present in the mainline
Linux kernel at some point.

Simon Horman (2):
  net: More fine-grained support for encapsulated GSO features
  net: Loosen constraints for recalculating checksum in skb_segment()

 include/linux/skbuff.h | 9 ++++++++-
 net/core/dev.c         | 2 +-
 net/core/skbuff.c      | 4 +++-
 net/ipv4/gre.c         | 1 +
 net/ipv4/ipip.c        | 1 +
 5 files changed, 14 insertions(+), 3 deletions(-)

-- 
1.8.2.1
