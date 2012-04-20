From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH net-next 00/19] net: Sysctl simplifications and enhancements
Date: Fri, 20 Apr 2012 12:45:52 +0400
Message-ID: <4F912240.8010802@parallels.com>
References: <m1aa27ia6h.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	"pablo@netfilter.org" <pablo@netfilter.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:31770 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751388Ab2DTIqM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Apr 2012 04:46:12 -0400
In-Reply-To: <m1aa27ia6h.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/20/2012 03:17 AM, Eric W. Biederman wrote:
> 
> Summary:
> - Kill approximately 400 lines of code
> - Allow all networking sysctls with just CAP_NET_ADMIN
> - Hide all networking sysctls that don't apply to your current network namespace.
> - Uniformly register flat sysctl tables not sysctl tables with .child entries
> - Readable string paths for registering sysctls
> 
> Eric W. Biederman (19):
>       net: Implement register_net_sysctl.
>       net sysctl:  Register an empty /proc/sys/net
>       net sysctl: Initialize the network sysctls sooner to avoid problems.
>       net: Kill register_sysctl_rotable
>       net: Move all of the network sysctls without a namespace into init_net.
>       net core: Remove unneded creation of an empty  net/core sysctl directory
>       net ipv6: Remove unneded registration of an empty net/ipv6/neigh
>       net ipv4: Remove the unneeded registration of an empty net/ipv4/neigh
>       net ax25: Simplify and cleanup the ax25 sysctl handling.
>       net llc: Don't use sysctl tables with .child entries.
>       net ipv6: Don't use sysctl tables with .child entries.
>       net neighbour:  Convert to use register_net_sysctl
>       net decnet:  Convert to use register_net_sysctl
>       net ipv6:  Convert addrconf to use register_net_sysctl
>       net ipv4:  Convert devinet to use register_net_sysctl
>       net: Convert nf_conntrack_proto to use register_net_sysctl
>       net: Convert all sysctl registrations to register_net_sysctl
>       net: Delete all remaining instances of ctl_path
>       net: Remove register_net_sysctl_table

After resolving issues with Eric

Acked-by: Pavel Emelyanov <xemul@parallels.com>

Thanks,
Pavel

>  drivers/infiniband/core/ucma.c                 |   10 +--
>  include/linux/netfilter.h                      |    6 --
>  include/net/ax25.h                             |   10 ++--
>  include/net/ip.h                               |    3 -
>  include/net/ip_vs.h                            |    2 -
>  include/net/ipv6.h                             |    3 -
>  include/net/net_namespace.h                    |   12 ++--
>  include/net/netfilter/nf_conntrack_l3proto.h   |    2 +-
>  include/net/netns/ipv6.h                       |    4 +-
>  net/802/tr.c                                   |    8 +--
>  net/appletalk/sysctl_net_atalk.c               |   10 +--
>  net/ax25/af_ax25.c                             |    2 -
>  net/ax25/ax25_dev.c                            |   10 +--
>  net/ax25/sysctl_net_ax25.c                     |   82 ++++++++---------------
>  net/bridge/br_netfilter.c                      |   10 +--
>  net/core/neighbour.c                           |   35 ++--------
>  net/core/sysctl_net_core.c                     |   14 +----
>  net/dccp/sysctl.c                              |   11 +---
>  net/decnet/dn_dev.c                            |   21 ++-----
>  net/decnet/sysctl_net_decnet.c                 |   10 +--
>  net/ipv4/devinet.c                             |   39 ++----------
>  net/ipv4/ip_fragment.c                         |    4 +-
>  net/ipv4/netfilter.c                           |   10 ---
>  net/ipv4/netfilter/ip_queue.c                  |    6 +-
>  net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |    2 +-
>  net/ipv4/route.c                               |   29 +--------
>  net/ipv4/sysctl_net_ipv4.c                     |   14 +---
>  net/ipv4/xfrm4_policy.c                        |    4 +-
>  net/ipv6/addrconf.c                            |   32 +--------
>  net/ipv6/af_inet6.c                            |   15 ----
>  net/ipv6/netfilter/ip6_queue.c                 |    6 +-
>  net/ipv6/netfilter/nf_conntrack_reasm.c        |    6 +-
>  net/ipv6/reassembly.c                          |    4 +-
>  net/ipv6/sysctl_net_ipv6.c                     |   83 +++++++-----------------
>  net/ipv6/xfrm6_policy.c                        |    4 +-
>  net/ipx/sysctl_net_ipx.c                       |   11 +--
>  net/irda/irsysctl.c                            |   10 +--
>  net/llc/sysctl_net_llc.c                       |   52 +++++----------
>  net/netfilter/core.c                           |    9 ---
>  net/netfilter/ipvs/ip_vs_ctl.c                 |   10 +---
>  net/netfilter/ipvs/ip_vs_lblc.c                |    3 +-
>  net/netfilter/ipvs/ip_vs_lblcr.c               |    3 +-
>  net/netfilter/nf_conntrack_acct.c              |    4 +-
>  net/netfilter/nf_conntrack_ecache.c            |    3 +-
>  net/netfilter/nf_conntrack_proto.c             |   10 ++--
>  net/netfilter/nf_conntrack_proto_dccp.c        |    4 +-
>  net/netfilter/nf_conntrack_standalone.c        |   14 +---
>  net/netfilter/nf_conntrack_timestamp.c         |    4 +-
>  net/netfilter/nf_log.c                         |    9 +--
>  net/netrom/sysctl_net_netrom.c                 |   10 +--
>  net/phonet/sysctl.c                            |   10 +--
>  net/rds/ib_sysctl.c                            |   11 +---
>  net/rds/iw_sysctl.c                            |   11 +---
>  net/rds/sysctl.c                               |   11 +---
>  net/rose/sysctl_net_rose.c                     |   10 +--
>  net/sctp/sysctl.c                              |   10 +--
>  net/socket.c                                   |    6 ++
>  net/sysctl_net.c                               |   45 ++++---------
>  net/unix/sysctl_net_unix.c                     |   10 +--
>  net/x25/sysctl_net_x25.c                       |   10 +--
>  net/xfrm/xfrm_sysctl.c                         |    2 +-
>  61 files changed, 209 insertions(+), 606 deletions(-)
> .
> 
