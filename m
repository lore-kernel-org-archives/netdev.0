From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [GIT net-next] Open vSwitch
Date: Mon,  6 Jan 2014 16:15:59 -0800
Message-ID: <1389053776-62865-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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

Open vSwitch changes for net-next/3.14. Highlights are:
 * Performance improvements in the mechanism to get packets to userspace
   using memory mapped netlink and skb zero copy where appropriate.
 * Per-cpu flow stats in situations where flows are likely to be shared
   across CPUs. Standard flow stats are used in other situations to save
   memory and allocation time.
 * A handful of code cleanups and rationalization.

The following changes since commit 6ce4eac1f600b34f2f7f58f9cd8f0503d79e42ae:

  Linux 3.13-rc1 (2013-11-22 11:30:55 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jesse/openvswitch.git master

for you to fetch changes up to 443cd88c8a31379e95326428bbbd40af25c1d440:

  ovs: make functions local (2014-01-06 15:54:39 -0800)

----------------------------------------------------------------
Andy Zhou (1):
      openvswitch: Change ovs_flow_tbl_lookup_xx() APIs

Ben Pfaff (2):
      openvswitch: Correct comment.
      openvswitch: Shrink sw_flow_mask by 8 bytes (64-bit) or 4 bytes (32-bit).

Daniel Borkmann (1):
      net: ovs: use kfree_rcu instead of rcu_free_{sw_flow_mask_cb,acts_callback}

Jesse Gross (1):
      openvswitch: Silence RCU lockdep checks from flow lookup.

Pravin B Shelar (1):
      openvswitch: Per cpu flow stats.

Stephen Hemminger (1):
      ovs: make functions local

Thomas Graf (9):
      genl: Add genlmsg_new_unicast() for unicast message allocation
      netlink: Avoid netlink mmap alloc if msg size exceeds frame size
      openvswitch: Enable memory mapped Netlink i/o
      net: Export skb_zerocopy() to zerocopy from one skb to another
      openvswitch: Allow user space to announce ability to accept unaligned Netlink messages
      openvswitch: Drop user features if old user space attempted to create datapath
      openvswitch: Pass datapath into userspace queue functions
      openvswitch: Use skb_zerocopy() for upcall
      openvswitch: Compute checksum in skb_gso_segment() if needed

Wei Yongjun (1):
      openvswitch: remove duplicated include from flow_table.c

 include/linux/skbuff.h               |   3 +
 include/net/genetlink.h              |   4 +
 include/uapi/linux/openvswitch.h     |  14 ++-
 net/core/skbuff.c                    |  85 +++++++++++++
 net/netfilter/nfnetlink_queue_core.c |  59 +--------
 net/netlink/af_netlink.c             |   4 +
 net/netlink/genetlink.c              |  21 ++++
 net/openvswitch/datapath.c           | 231 +++++++++++++++++++----------------
 net/openvswitch/datapath.h           |   6 +-
 net/openvswitch/flow.c               |  96 +++++++++++++--
 net/openvswitch/flow.h               |  33 +++--
 net/openvswitch/flow_netlink.c       |  66 ++++++++--
 net/openvswitch/flow_netlink.h       |   1 +
 net/openvswitch/flow_table.c         |  60 ++++++---
 net/openvswitch/flow_table.h         |   6 +-
 net/openvswitch/vport.c              |   6 +-
 net/openvswitch/vport.h              |   1 -
 17 files changed, 483 insertions(+), 213 deletions(-)
