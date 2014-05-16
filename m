From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [GIT net-next] Open vSwitch
Date: Fri, 16 May 2014 14:07:27 -0700
Message-ID: <1400274459-56304-1-git-send-email-jesse@nicira.com>
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
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

A set of OVS changes for net-next/3.16.

The major change here is a switch from per-CPU to per-NUMA flow
statistics. This improves scalability by reducing kernel overhead
in flow setup and maintenance.

The following changes since commit a188a54d11629bef2169052297e61f3767ca8ce5:

  macvlan: simplify the structure port (2014-05-15 23:35:16 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jesse/openvswitch.git master

for you to fetch changes up to 944df8ae84d88f5e8eb027990dad2cfa4fbe4be5:

  net/openvswitch: Use with RCU_INIT_POINTER(x, NULL) in vport-gre.c (2014-05-16 13:40:29 -0700)

----------------------------------------------------------------
Daniele Di Proietto (4):
      openvswitch: use const in some local vars and casts
      openvswitch: avoid warnings in vport_from_priv
      openvswitch: avoid cast-qual warning in vport_priv
      openvswitch: Added (unsigned long long) cast in printf

Jarno Rajahalme (4):
      openvswitch: Remove 5-tuple optimization.
      openvswitch: Per NUMA node flow stats.
      openvswitch: Fix output of SCTP mask.
      openvswitch: Use TCP flags in the flow key for stats.

Joe Perches (3):
      openvswitch: Use net_ratelimit in OVS_NLERR
      openvswitch: flow_netlink: Use pr_fmt to OVS_NLERR output
      openvswitch: Use ether_addr_copy

Monam Agarwal (1):
      net/openvswitch: Use with RCU_INIT_POINTER(x, NULL) in vport-gre.c

 net/openvswitch/actions.c      |   4 +-
 net/openvswitch/datapath.c     |  11 ++-
 net/openvswitch/datapath.h     |   8 ++-
 net/openvswitch/flow.c         | 149 ++++++++++++++++++++++++-----------------
 net/openvswitch/flow.h         |  18 +++--
 net/openvswitch/flow_netlink.c |  82 +++++------------------
 net/openvswitch/flow_netlink.h |   1 -
 net/openvswitch/flow_table.c   |  75 ++++++++++++---------
 net/openvswitch/flow_table.h   |   4 +-
 net/openvswitch/vport-gre.c    |   2 +-
 net/openvswitch/vport.h        |   6 +-
 11 files changed, 176 insertions(+), 184 deletions(-)
