From: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next v2 00/12] openvswitch: gre tunneling
	support.
Date: Mon, 17 Jun 2013 17:49:21 -0700
Message-ID: <1371516561-17622-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
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

Following patch series adds support for gre tunneling.
First six patches extend kernel gre and ip_tunnel modules
api so that there is more code sharing between gre modules
and ovs. Rest of patches adds ovs tunneling infrastructre
and gre protocol vport.

V2 fixes two patches according to comments from Jesse.

Pravin B Shelar (12):
  gre: Simplify gre protocol registration locking.
  gre: Allow multiple protocol listener for gre protocol.
  gre: export gre_build_header() function.
  gre: export gre_handle_offloads() function.
  ip_tunnels: extend iptunnel_xmit()
  ip_tunnel: push generic protocol handling to ip_tunnel module.
  ip_tunnel: Add dont fragment flag.
  openvswitch: Copy individual actions.
  openvswitch: Add tunneling interface.
  openvswitch: Expand action buffer size.
  openvswitch: Optimize flow key match for non tunnel flows.
  openvswitch: Add gre tunnel support.

 drivers/net/vxlan.c                  |   32 +---
 include/net/gre.h                    |   27 +++
 include/net/ip_tunnels.h             |   28 ++-
 include/uapi/linux/openvswitch.h     |   19 ++
 net/ipv4/Makefile                    |    2 +-
 net/ipv4/gre.c                       |  323 ++++++++++++++++++++++++++++---
 net/ipv4/ip_gre.c                    |  247 +++---------------------
 net/ipv4/ip_tunnel.c                 |   68 ++-----
 net/ipv4/ip_tunnel_core.c            |  121 ++++++++++++
 net/ipv4/ipip.c                      |    6 +-
 net/ipv6/sit.c                       |   44 ++---
 net/openvswitch/Makefile             |    3 +-
 net/openvswitch/actions.c            |    4 +
 net/openvswitch/datapath.c           |  356 ++++++++++++++++++++++++++++------
 net/openvswitch/datapath.h           |    4 +
 net/openvswitch/flow.c               |  186 ++++++++++++++++--
 net/openvswitch/flow.h               |   45 ++++-
 net/openvswitch/vport-gre.c          |  274 ++++++++++++++++++++++++++
 net/openvswitch/vport-internal_dev.c |    2 +-
 net/openvswitch/vport-netdev.c       |    2 +-
 net/openvswitch/vport.c              |   23 ++-
 net/openvswitch/vport.h              |   10 +-
 22 files changed, 1370 insertions(+), 456 deletions(-)
 create mode 100644 net/ipv4/ip_tunnel_core.c
 create mode 100644 net/openvswitch/vport-gre.c
