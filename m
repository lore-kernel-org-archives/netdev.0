From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: [PATCH v2.53] datapath: Add basic MPLS support to kernel
Date: Wed,  5 Feb 2014 17:54:38 +0900
Message-ID: <1391590479-15567-1-git-send-email-horms@verge.net.au>
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

after somewhat of a hiatus I would like to once again
bring this patch onto the table. Since I posted the previous version
(v2.52) a two key things have changed.

* Ben's new approach to MPLS in userspace has been merged.
  Thus there are no user-space patches in this series.

* Ben has explained to me that there has been a change of direction
  at the ONF with regards to MPLS and VLAN tag ordering. As per
  his changelog for "Always insert MPLS labels after VLAN tags",
  the situation is now as follows:

  * OpenFlow 1.1 and 1.2 always inserted MPLS labels after VLAN tags.
  * OpenFlow 1.3 and 1.4 insert MPLS labels before VLAN tags.
  * OpenFlow 1.3.4 and 1.5, both in preparation, recognize that the change
    in 1.3 was an error and revert it.

  With this in mind only OF1.4 specifies a requirement for inserting MPLS
  labels before VLAN tags. This appears to be an abbertation at this
  point.

  Ben's suggestion as per his patch "Always insert MPLS labels after VLAN
  tags" is that Open vSwtich should only support inserting MPLS labels
  after VLAN tags. I agree with this. And to this end I have
  updated the MPLS code for the kernel datapath (this patch).

  I realise this has been a point of much discussion in the past
  but with the change in direction of ONF I think that it is
  worth reconsidering things and thus I am submitting this patch for
  review in this form.


This patch depends on "Always insert MPLS labels after VLAN tags",
which was posed by Ben and I believe he is planning to merge.

to aid review this patch and its dependency are available in git at:
https://github.com/horms/openvswitch devel/mpls-v2.53


Simon Horman (1):
  datapath: Add basic MPLS support to kernel

 OPENFLOW-1.1+                                   |  12 -
 datapath/Modules.mk                             |   1 +
 datapath/actions.c                              | 121 +++++++++-
 datapath/datapath.c                             |   4 +-
 datapath/flow.c                                 |  29 +++
 datapath/flow.h                                 |  17 +-
 datapath/flow_netlink.c                         | 286 ++++++++++++++++++++++--
 datapath/flow_netlink.h                         |   2 +-
 datapath/linux/compat/gso.c                     |  70 +++++-
 datapath/linux/compat/gso.h                     |  41 ++++
 datapath/linux/compat/include/linux/netdevice.h |   6 +-
 datapath/linux/compat/netdevice.c               |  10 +-
 datapath/mpls.h                                 |  15 ++
 include/linux/openvswitch.h                     |   7 +-
 14 files changed, 559 insertions(+), 62 deletions(-)
 create mode 100644 datapath/mpls.h

-- 
1.8.5.2
