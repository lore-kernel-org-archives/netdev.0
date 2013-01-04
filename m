From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 3.0.y 0/3] rtnetlink: Fix problem with buffer allocation
Date: Fri, 4 Jan 2013 00:30:49 +0000
Message-ID: <1357259449.2685.60.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Greg Rose <gregory.v.rose@intel.com>, <stable@vger.kernel.org>,
	<e1000-devel@lists.sourceforge.net>, <netdev@vger.kernel.org>,
	<linux-net-drivers@solarflare.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches fix the problem that interface information including many
VFs is too large for the 4K buffers used by glibc and other clients.
This breaks many network services.

The first of these ('rtnetlink: Compute and store minimum ifinfo dump
size') went into 3.1 and has also been included in SLE11 SP2.  The
second and third were acked by David Miller and included in 3.2.34.

I've applied and briefly tested these changes in conjunction with a
backport of the sfc driver to SLE11 SP3.

Ben.

Eric Dumazet (1):
  rtnetlink: fix rtnl_calcit() and rtnl_dump_ifinfo()

Greg Rose (2):
  rtnetlink: Compute and store minimum ifinfo dump size
  rtnetlink: Fix problem with buffer allocation

 drivers/infiniband/core/netlink.c    |    2 +-
 include/linux/if_link.h              |    1 +
 include/linux/netlink.h              |    6 +-
 include/linux/rtnetlink.h            |    3 +
 include/net/rtnetlink.h              |    7 ++-
 net/bridge/br_netlink.c              |   15 +++--
 net/core/fib_rules.c                 |    6 +-
 net/core/neighbour.c                 |   11 ++--
 net/core/rtnetlink.c                 |  127 +++++++++++++++++++++++++++-------
 net/dcb/dcbnl.c                      |    4 +-
 net/decnet/dn_dev.c                  |    6 +-
 net/decnet/dn_fib.c                  |    4 +-
 net/decnet/dn_route.c                |    5 +-
 net/ipv4/devinet.c                   |    6 +-
 net/ipv4/fib_frontend.c              |    6 +-
 net/ipv4/inet_diag.c                 |    2 +-
 net/ipv4/ipmr.c                      |    3 +-
 net/ipv4/route.c                     |    2 +-
 net/ipv6/addrconf.c                  |   16 +++--
 net/ipv6/addrlabel.c                 |    9 ++-
 net/ipv6/ip6_fib.c                   |    3 +-
 net/ipv6/ip6mr.c                     |    3 +-
 net/ipv6/route.c                     |    6 +-
 net/netfilter/ipset/ip_set_core.c    |    2 +-
 net/netfilter/nf_conntrack_netlink.c |    4 +-
 net/netlink/af_netlink.c             |   17 +++--
 net/netlink/genetlink.c              |    2 +-
 net/phonet/pn_netlink.c              |   13 ++--
 net/sched/act_api.c                  |    7 +-
 net/sched/cls_api.c                  |    6 +-
 net/sched/sch_api.c                  |   12 ++--
 net/xfrm/xfrm_user.c                 |    3 +-
 32 files changed, 216 insertions(+), 103 deletions(-)


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
