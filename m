From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [GIT net-next] Open vSwitch
Date: Sat,  2 Nov 2013 00:43:39 -0700
Message-ID: <1383378230-59624-1-git-send-email-jesse@nicira.com>
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

A set of updates for net-next/3.13. Major changes are:
 * Restructure flow handling code to be more logically organized and
   easier to read.
 * Rehashing of the flow table is moved from a workqueue to flow
   installation time. Before, heavy load could block the workqueue for
   excessive periods of time.
 * Additional debugging information is provided to help diagnose megaflows.
 * It's now possible to match on TCP flags.

The following changes since commit 272b98c6455f00884f0350f775c5342358ebb73f:

  Linux 3.12-rc1 (2013-09-16 16:17:51 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jesse/openvswitch.git master

for you to fetch changes up to 8ddd094675cfd453fc9838caa46ea108a4107183:

  openvswitch: Use flow hash during flow lookup operation. (2013-11-01 18:43:46 -0700)

----------------------------------------------------------------
Andy Zhou (1):
      openvswitch: collect mega flow mask stats

Jarno Rajahalme (2):
      openvswitch: Widen TCP flags handling.
      openvswitch: TCP flags matching support.

Pravin B Shelar (6):
      openvswitch: Move flow table rehashing to flow install.
      openvswitch: Restructure datapath.c and flow.c
      openvswitch: Move mega-flow list out of rehashing struct.
      openvswitch: Simplify mega-flow APIs.
      openvswitch: Enable all GSO features on internal port.
      openvswitch: Use flow hash during flow lookup operation.

Wei Yongjun (2):
      openvswitch: remove duplicated include from vport-vxlan.c
      openvswitch: remove duplicated include from vport-gre.c

 include/uapi/linux/openvswitch.h     |   18 +-
 net/openvswitch/Makefile             |    2 +
 net/openvswitch/datapath.c           |  668 ++------------
 net/openvswitch/datapath.h           |    9 +-
 net/openvswitch/flow.c               | 1605 +--------------------------------
 net/openvswitch/flow.h               |  132 +--
 net/openvswitch/flow_netlink.c       | 1630 ++++++++++++++++++++++++++++++++++
 net/openvswitch/flow_netlink.h       |   60 ++
 net/openvswitch/flow_table.c         |  592 ++++++++++++
 net/openvswitch/flow_table.h         |   81 ++
 net/openvswitch/vport-gre.c          |    2 -
 net/openvswitch/vport-internal_dev.c |    2 +-
 net/openvswitch/vport-vxlan.c        |    1 -
 13 files changed, 2511 insertions(+), 2291 deletions(-)
 create mode 100644 net/openvswitch/flow_netlink.c
 create mode 100644 net/openvswitch/flow_netlink.h
 create mode 100644 net/openvswitch/flow_table.c
 create mode 100644 net/openvswitch/flow_table.h
