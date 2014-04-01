From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: [PATCH v2.56] datapath: Add basic MPLS support to kernel
Date: Tue,  1 Apr 2014 12:46:20 +0900
Message-ID: <1396323981-20700-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Ravi K <rkerur-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>, Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
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

Hi Jesse, Hi Pravin, Hi All,

This patchset makes use of a whitelist to only allow mpls_push actions to
be applied to packets with an ethertype where the tag order is well defined
and implemented. This avoids the problem of where an MPLS LSE should be
added in relation to a VLAN or similar tag.

The list of allowed ethertypes is currently:

  - ETH_P_IP (0x0800)
  - ETH_P_ARP (0x0806)
  - ETH_P_RARP (0x0835)
  - ETH_P_IPV6 (0x86DD)
  - ETH_P_MPLS_UC (0x8847)
  - ETH_P_MPLS_MC (0x8847)


I have updated this patch since v2.55 so that:

* The MPLS ethertypes are included in the whitelist of ethertypes
  that allow mpls_push actions.
* It once again applies on top of the master branch


Simon Horman (1):
  datapath: Add basic MPLS support to kernel

 OPENFLOW-1.1+                                   |   4 -
 datapath/Modules.mk                             |   1 +
 datapath/actions.c                              | 119 +++++++++-
 datapath/datapath.c                             |   4 +-
 datapath/flow.c                                 |  29 +++
 datapath/flow.h                                 |  17 +-
 datapath/flow_netlink.c                         | 298 ++++++++++++++++++++++--
 datapath/flow_netlink.h                         |   2 +-
 datapath/linux/compat/gso.c                     |  70 +++++-
 datapath/linux/compat/gso.h                     |  41 +++-
 datapath/linux/compat/include/linux/netdevice.h |   6 +-
 datapath/linux/compat/netdevice.c               |  10 +-
 datapath/mpls.h                                 |  15 ++
 include/linux/openvswitch.h                     |   9 +-
 14 files changed, 568 insertions(+), 57 deletions(-)
 create mode 100644 datapath/mpls.h

-- 
1.8.4
