From: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Subject: [PATCH 0/2 v3] Open vSwitch zerocopy upcall
Date: Fri,  8 Nov 2013 10:15:18 +0100
Message-ID: <cover.1383901577.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
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

Respin of the zerocopy patches for the openvswitch upcall.

V3: - Removed unneeded alignment of nlmsg_len after padding 
V2: - Added skb_zerocopy_headlen() to calculate headroom of destination
      buffer. This also takes care of the from->head_frag issue.
    - Attribute alignment for frag_list case
    - API documentation
    - performance data for CHECKSUM_PARTIAL tx case


Thomas Graf (2):
  net: Export skb_zerocopy() to zerocopy from one skb to another
  openvswitch: Use skb_zerocopy() for upcall

 include/linux/skbuff.h               |  3 ++
 net/core/skbuff.c                    | 85 ++++++++++++++++++++++++++++++++++++
 net/netfilter/nfnetlink_queue_core.c | 59 ++-----------------------
 net/openvswitch/datapath.c           | 52 +++++++++++++++++++---
 4 files changed, 137 insertions(+), 62 deletions(-)

-- 
1.8.3.1
