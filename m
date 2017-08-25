From: Yi Yang <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next v6 0/3] openvswitch: add NSH support
Date: Fri, 25 Aug 2017 22:20:02 +0800
Message-ID: <1503670805-31051-1-git-send-email-yi.y.yang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, e@erig.me
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Unsubscribe: <https://mail.openvswitch.org/mailman/options/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://mail.openvswitch.org/pipermail/ovs-dev/>
List-Post: <mailto:ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <https://mail.openvswitch.org/mailman/listinfo/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

v5->v6
 - Fix the rest comments for v4.
 - Add NSH GSO support for VxLAN-gpe + NSH and
   Eth + NSH.

v4->v5
 - Fix many comments by Jiri Benc and Eric Garver
   for v4.

v3->v4
 - Add new NSH match field ttl
 - Update NSH header to the latest format
   which will be final format and won't change
   per its author's confirmation.
 - Fix comments for v3.

v2->v3
 - Change OVS_KEY_ATTR_NSH to nested key to handle
   length-fixed attributes and length-variable
   attriubte more flexibly.
 - Remove struct ovs_action_push_nsh completely
 - Add code to handle nested attribute for SET_MASKED
 - Change PUSH_NSH to use the nested OVS_KEY_ATTR_NSH
   to transfer NSH header data.
 - Fix comments and coding style issues by Jiri and Eric

v1->v2
 - Change encap_nsh and decap_nsh to push_nsh and pop_nsh
 - Dynamically allocate struct ovs_action_push_nsh for
   length-variable metadata.

This patch series is to enable NSH support in OVS kernel
data path, it also adds NSH GSO support for big packet.

Yi Yang (3):
  net: add NSH header structures and helpers
  net: gso: Add GSO support for NSH
  openvswitch: enable NSH support

 drivers/net/vxlan.c              |   7 +
 include/linux/netdevice.h        |   1 +
 include/linux/skbuff.h           |   8 +-
 include/net/nsh.h                | 307 +++++++++++++++++++++++++++++
 include/uapi/linux/if_ether.h    |   1 +
 include/uapi/linux/openvswitch.h |  28 +++
 net/Kconfig                      |   1 +
 net/Makefile                     |   1 +
 net/core/dev.c                   |  14 ++
 net/ipv4/udp_offload.c           |   7 +
 net/nsh/Kconfig                  |  11 ++
 net/nsh/Makefile                 |   4 +
 net/nsh/nsh_gso.c                | 106 ++++++++++
 net/openvswitch/actions.c        | 178 +++++++++++++++++
 net/openvswitch/flow.c           |  55 ++++++
 net/openvswitch/flow.h           |  11 ++
 net/openvswitch/flow_netlink.c   | 404 ++++++++++++++++++++++++++++++++++++++-
 net/openvswitch/flow_netlink.h   |   4 +
 18 files changed, 1145 insertions(+), 3 deletions(-)
 create mode 100644 include/net/nsh.h
 create mode 100644 net/nsh/Kconfig
 create mode 100644 net/nsh/Makefile
 create mode 100644 net/nsh/nsh_gso.c

-- 
2.5.5
