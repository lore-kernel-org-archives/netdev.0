From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: [PATCH v2.54] datapath: Add basic MPLS support to kernel
Date: Wed, 12 Feb 2014 12:52:39 +0900
Message-ID: <1392177160-18742-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Ravi K <rkerur-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>, Ben Pfaff <blp-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
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

Hi Jesse, Hi All,

As per the suggestion made by Ben in relation to this patch
I have updated it so that:

* The datapath rejects push MPLS actions in the presence of VLAN tags.

  I have done this by blacklisting the following:
  - ETH_P_8021Q (0x8100)
  - ETH_P_8021AD (0x88A8)
  - ETH_P_QINQ1 (0x0x9100)
  - ETH_P_QINQ2 (0x0x9200)
  - ETH_P_QINQ3 (0x0x9300)

  But perhaps a safer option would be to whitelist only ethertypes
  we are completely comfortable with. Starting with:
  - ETH_P_IP (0x0800)
  - ETH_P_ARP (0x0806)
  - ETH_P_IPV6 (0x86DD)


to aid review this patch is available in git at:
https://github.com/horms/openvswitch devel/mpls-v2.54

Simon Horman (1):
  datapath: Add basic MPLS support to kernel

 OPENFLOW-1.1+                                   |  12 -
 datapath/Modules.mk                             |   1 +
 datapath/actions.c                              | 119 +++++++++-
 datapath/datapath.c                             |   4 +-
 datapath/flow.c                                 |  29 +++
 datapath/flow.h                                 |  17 +-
 datapath/flow_netlink.c                         | 296 ++++++++++++++++++++++--
 datapath/flow_netlink.h                         |   2 +-
 datapath/linux/compat/gso.c                     |  70 +++++-
 datapath/linux/compat/gso.h                     |  41 ++++
 datapath/linux/compat/include/linux/netdevice.h |   6 +-
 datapath/linux/compat/netdevice.c               |  10 +-
 datapath/mpls.h                                 |  15 ++
 include/linux/openvswitch.h                     |   7 +-
 14 files changed, 567 insertions(+), 62 deletions(-)
 create mode 100644 datapath/mpls.h

-- 
1.8.5.2
