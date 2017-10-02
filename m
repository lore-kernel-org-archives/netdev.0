From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH iproute2] iproute: build more easily on Android
Date: Tue,  3 Oct 2017 02:03:37 +0900
Message-ID: <20171002170337.42235-1-lorenzo@google.com>
Cc: stephen@networkplumber.org, enh@google.com,
        Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:51885 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750957AbdJBRDp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 13:03:45 -0400
Received: by mail-pf0-f174.google.com with SMTP id n14so1289367pfh.8
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 10:03:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

iproute2 contains a bunch of kernel headers, including uapi ones.
Android's libc uses uapi headers almost directly, and uses a
script to fix kernel types that don't match what userspace
expects.

For example: https://issuetracker.google.com/36987220 reports
that our struct ip_mreq_source contains "__be32 imr_multiaddr"
rather than "struct in_addr imr_multiaddr". The script addresses
this by replacing the uapi struct definition with a #include
<bits/ip_mreq.h> which contains the traditional userspace
definition.

Unfortunately, when we compile iproute2, this definition
conflicts with the one in iproute2's linux/in.h.

Historically we've just solved this problem by running "git rm"
on all the iproute2 include/linux headers that break Android's
libc.  However, deleting the files in this way makes it harder to
keep up with upstream, because every upstream change to
an include file causes a merge conflict with the delete.

This patch fixes the problem by moving the iproute2 linux headers
from include/linux to include/uapi/linux.

Tested: compiles on ubuntu trusty (glibc)

Signed-off-by: Elliott Hughes <enh@google.com>
Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 Makefile                                             | 2 +-
 include/{ => uapi}/linux/atm.h                       | 0
 include/{ => uapi}/linux/atmapi.h                    | 0
 include/{ => uapi}/linux/atmarp.h                    | 0
 include/{ => uapi}/linux/atmdev.h                    | 0
 include/{ => uapi}/linux/atmioc.h                    | 0
 include/{ => uapi}/linux/atmsap.h                    | 0
 include/{ => uapi}/linux/bpf.h                       | 0
 include/{ => uapi}/linux/bpf_common.h                | 0
 include/{ => uapi}/linux/can.h                       | 0
 include/{ => uapi}/linux/can/netlink.h               | 0
 include/{ => uapi}/linux/can/vxcan.h                 | 0
 include/{ => uapi}/linux/devlink.h                   | 0
 include/{ => uapi}/linux/elf-em.h                    | 0
 include/{ => uapi}/linux/fib_rules.h                 | 0
 include/{ => uapi}/linux/filter.h                    | 0
 include/{ => uapi}/linux/fou.h                       | 0
 include/{ => uapi}/linux/gen_stats.h                 | 0
 include/{ => uapi}/linux/genetlink.h                 | 0
 include/{ => uapi}/linux/hdlc/ioctl.h                | 0
 include/{ => uapi}/linux/icmpv6.h                    | 0
 include/{ => uapi}/linux/if.h                        | 0
 include/{ => uapi}/linux/if_addr.h                   | 0
 include/{ => uapi}/linux/if_addrlabel.h              | 0
 include/{ => uapi}/linux/if_alg.h                    | 0
 include/{ => uapi}/linux/if_arp.h                    | 0
 include/{ => uapi}/linux/if_bonding.h                | 0
 include/{ => uapi}/linux/if_bridge.h                 | 0
 include/{ => uapi}/linux/if_ether.h                  | 0
 include/{ => uapi}/linux/if_link.h                   | 0
 include/{ => uapi}/linux/if_macsec.h                 | 0
 include/{ => uapi}/linux/if_packet.h                 | 0
 include/{ => uapi}/linux/if_tun.h                    | 0
 include/{ => uapi}/linux/if_tunnel.h                 | 0
 include/{ => uapi}/linux/if_vlan.h                   | 0
 include/{ => uapi}/linux/ife.h                       | 0
 include/{ => uapi}/linux/ila.h                       | 0
 include/{ => uapi}/linux/in.h                        | 0
 include/{ => uapi}/linux/in6.h                       | 0
 include/{ => uapi}/linux/in_route.h                  | 0
 include/{ => uapi}/linux/inet_diag.h                 | 0
 include/{ => uapi}/linux/ip.h                        | 0
 include/{ => uapi}/linux/ip6_tunnel.h                | 0
 include/{ => uapi}/linux/ipsec.h                     | 0
 include/{ => uapi}/linux/kernel.h                    | 0
 include/{ => uapi}/linux/l2tp.h                      | 0
 include/{ => uapi}/linux/libc-compat.h               | 0
 include/{ => uapi}/linux/limits.h                    | 0
 include/{ => uapi}/linux/lwtunnel.h                  | 0
 include/{ => uapi}/linux/magic.h                     | 0
 include/{ => uapi}/linux/mpls.h                      | 0
 include/{ => uapi}/linux/mpls_iptunnel.h             | 0
 include/{ => uapi}/linux/neighbour.h                 | 0
 include/{ => uapi}/linux/net_namespace.h             | 0
 include/{ => uapi}/linux/netconf.h                   | 0
 include/{ => uapi}/linux/netdevice.h                 | 0
 include/{ => uapi}/linux/netfilter.h                 | 0
 include/{ => uapi}/linux/netfilter/ipset/ip_set.h    | 0
 include/{ => uapi}/linux/netfilter/x_tables.h        | 0
 include/{ => uapi}/linux/netfilter/xt_set.h          | 0
 include/{ => uapi}/linux/netfilter/xt_tcpudp.h       | 0
 include/{ => uapi}/linux/netfilter_ipv4.h            | 0
 include/{ => uapi}/linux/netfilter_ipv4/ip_tables.h  | 0
 include/{ => uapi}/linux/netfilter_ipv6.h            | 0
 include/{ => uapi}/linux/netfilter_ipv6/ip6_tables.h | 0
 include/{ => uapi}/linux/netlink.h                   | 0
 include/{ => uapi}/linux/netlink_diag.h              | 0
 include/{ => uapi}/linux/packet_diag.h               | 0
 include/{ => uapi}/linux/param.h                     | 0
 include/{ => uapi}/linux/pfkeyv2.h                   | 0
 include/{ => uapi}/linux/pkt_cls.h                   | 0
 include/{ => uapi}/linux/pkt_sched.h                 | 0
 include/{ => uapi}/linux/posix_types.h               | 0
 include/{ => uapi}/linux/rtnetlink.h                 | 0
 include/{ => uapi}/linux/sctp.h                      | 0
 include/{ => uapi}/linux/seg6.h                      | 0
 include/{ => uapi}/linux/seg6_genl.h                 | 0
 include/{ => uapi}/linux/seg6_hmac.h                 | 0
 include/{ => uapi}/linux/seg6_iptunnel.h             | 0
 include/{ => uapi}/linux/seg6_local.h                | 0
 include/{ => uapi}/linux/sock_diag.h                 | 0
 include/{ => uapi}/linux/socket.h                    | 0
 include/{ => uapi}/linux/sockios.h                   | 0
 include/{ => uapi}/linux/stddef.h                    | 0
 include/{ => uapi}/linux/sysinfo.h                   | 0
 include/{ => uapi}/linux/tc_act/tc_bpf.h             | 0
 include/{ => uapi}/linux/tc_act/tc_connmark.h        | 0
 include/{ => uapi}/linux/tc_act/tc_csum.h            | 0
 include/{ => uapi}/linux/tc_act/tc_defact.h          | 0
 include/{ => uapi}/linux/tc_act/tc_gact.h            | 0
 include/{ => uapi}/linux/tc_act/tc_ife.h             | 0
 include/{ => uapi}/linux/tc_act/tc_ipt.h             | 0
 include/{ => uapi}/linux/tc_act/tc_mirred.h          | 0
 include/{ => uapi}/linux/tc_act/tc_nat.h             | 0
 include/{ => uapi}/linux/tc_act/tc_pedit.h           | 0
 include/{ => uapi}/linux/tc_act/tc_sample.h          | 0
 include/{ => uapi}/linux/tc_act/tc_skbedit.h         | 0
 include/{ => uapi}/linux/tc_act/tc_skbmod.h          | 0
 include/{ => uapi}/linux/tc_act/tc_tunnel_key.h      | 0
 include/{ => uapi}/linux/tc_act/tc_vlan.h            | 0
 include/{ => uapi}/linux/tc_ematch/tc_em_cmp.h       | 0
 include/{ => uapi}/linux/tc_ematch/tc_em_meta.h      | 0
 include/{ => uapi}/linux/tc_ematch/tc_em_nbyte.h     | 0
 include/{ => uapi}/linux/tcp.h                       | 0
 include/{ => uapi}/linux/tcp_metrics.h               | 0
 include/{ => uapi}/linux/tipc.h                      | 0
 include/{ => uapi}/linux/tipc_netlink.h              | 0
 include/{ => uapi}/linux/types.h                     | 0
 include/{ => uapi}/linux/unix_diag.h                 | 0
 include/{ => uapi}/linux/veth.h                      | 0
 include/{ => uapi}/linux/xfrm.h                      | 0
 111 files changed, 1 insertion(+), 1 deletion(-)
 rename include/{ => uapi}/linux/atm.h (100%)
 rename include/{ => uapi}/linux/atmapi.h (100%)
 rename include/{ => uapi}/linux/atmarp.h (100%)
 rename include/{ => uapi}/linux/atmdev.h (100%)
 rename include/{ => uapi}/linux/atmioc.h (100%)
 rename include/{ => uapi}/linux/atmsap.h (100%)
 rename include/{ => uapi}/linux/bpf.h (100%)
 rename include/{ => uapi}/linux/bpf_common.h (100%)
 rename include/{ => uapi}/linux/can.h (100%)
 rename include/{ => uapi}/linux/can/netlink.h (100%)
 rename include/{ => uapi}/linux/can/vxcan.h (100%)
 rename include/{ => uapi}/linux/devlink.h (100%)
 rename include/{ => uapi}/linux/elf-em.h (100%)
 rename include/{ => uapi}/linux/fib_rules.h (100%)
 rename include/{ => uapi}/linux/filter.h (100%)
 rename include/{ => uapi}/linux/fou.h (100%)
 rename include/{ => uapi}/linux/gen_stats.h (100%)
 rename include/{ => uapi}/linux/genetlink.h (100%)
 rename include/{ => uapi}/linux/hdlc/ioctl.h (100%)
 rename include/{ => uapi}/linux/icmpv6.h (100%)
 rename include/{ => uapi}/linux/if.h (100%)
 rename include/{ => uapi}/linux/if_addr.h (100%)
 rename include/{ => uapi}/linux/if_addrlabel.h (100%)
 rename include/{ => uapi}/linux/if_alg.h (100%)
 rename include/{ => uapi}/linux/if_arp.h (100%)
 rename include/{ => uapi}/linux/if_bonding.h (100%)
 rename include/{ => uapi}/linux/if_bridge.h (100%)
 rename include/{ => uapi}/linux/if_ether.h (100%)
 rename include/{ => uapi}/linux/if_link.h (100%)
 rename include/{ => uapi}/linux/if_macsec.h (100%)
 rename include/{ => uapi}/linux/if_packet.h (100%)
 rename include/{ => uapi}/linux/if_tun.h (100%)
 rename include/{ => uapi}/linux/if_tunnel.h (100%)
 rename include/{ => uapi}/linux/if_vlan.h (100%)
 rename include/{ => uapi}/linux/ife.h (100%)
 rename include/{ => uapi}/linux/ila.h (100%)
 rename include/{ => uapi}/linux/in.h (100%)
 rename include/{ => uapi}/linux/in6.h (100%)
 rename include/{ => uapi}/linux/in_route.h (100%)
 rename include/{ => uapi}/linux/inet_diag.h (100%)
 rename include/{ => uapi}/linux/ip.h (100%)
 rename include/{ => uapi}/linux/ip6_tunnel.h (100%)
 rename include/{ => uapi}/linux/ipsec.h (100%)
 rename include/{ => uapi}/linux/kernel.h (100%)
 rename include/{ => uapi}/linux/l2tp.h (100%)
 rename include/{ => uapi}/linux/libc-compat.h (100%)
 rename include/{ => uapi}/linux/limits.h (100%)
 rename include/{ => uapi}/linux/lwtunnel.h (100%)
 rename include/{ => uapi}/linux/magic.h (100%)
 rename include/{ => uapi}/linux/mpls.h (100%)
 rename include/{ => uapi}/linux/mpls_iptunnel.h (100%)
 rename include/{ => uapi}/linux/neighbour.h (100%)
 rename include/{ => uapi}/linux/net_namespace.h (100%)
 rename include/{ => uapi}/linux/netconf.h (100%)
 rename include/{ => uapi}/linux/netdevice.h (100%)
 rename include/{ => uapi}/linux/netfilter.h (100%)
 rename include/{ => uapi}/linux/netfilter/ipset/ip_set.h (100%)
 rename include/{ => uapi}/linux/netfilter/x_tables.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_set.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_tcpudp.h (100%)
 rename include/{ => uapi}/linux/netfilter_ipv4.h (100%)
 rename include/{ => uapi}/linux/netfilter_ipv4/ip_tables.h (100%)
 rename include/{ => uapi}/linux/netfilter_ipv6.h (100%)
 rename include/{ => uapi}/linux/netfilter_ipv6/ip6_tables.h (100%)
 rename include/{ => uapi}/linux/netlink.h (100%)
 rename include/{ => uapi}/linux/netlink_diag.h (100%)
 rename include/{ => uapi}/linux/packet_diag.h (100%)
 rename include/{ => uapi}/linux/param.h (100%)
 rename include/{ => uapi}/linux/pfkeyv2.h (100%)
 rename include/{ => uapi}/linux/pkt_cls.h (100%)
 rename include/{ => uapi}/linux/pkt_sched.h (100%)
 rename include/{ => uapi}/linux/posix_types.h (100%)
 rename include/{ => uapi}/linux/rtnetlink.h (100%)
 rename include/{ => uapi}/linux/sctp.h (100%)
 rename include/{ => uapi}/linux/seg6.h (100%)
 rename include/{ => uapi}/linux/seg6_genl.h (100%)
 rename include/{ => uapi}/linux/seg6_hmac.h (100%)
 rename include/{ => uapi}/linux/seg6_iptunnel.h (100%)
 rename include/{ => uapi}/linux/seg6_local.h (100%)
 rename include/{ => uapi}/linux/sock_diag.h (100%)
 rename include/{ => uapi}/linux/socket.h (100%)
 rename include/{ => uapi}/linux/sockios.h (100%)
 rename include/{ => uapi}/linux/stddef.h (100%)
 rename include/{ => uapi}/linux/sysinfo.h (100%)
 rename include/{ => uapi}/linux/tc_act/tc_bpf.h (100%)
 rename include/{ => uapi}/linux/tc_act/tc_connmark.h (100%)
 rename include/{ => uapi}/linux/tc_act/tc_csum.h (100%)
 rename include/{ => uapi}/linux/tc_act/tc_defact.h (100%)
 rename include/{ => uapi}/linux/tc_act/tc_gact.h (100%)
 rename include/{ => uapi}/linux/tc_act/tc_ife.h (100%)
 rename include/{ => uapi}/linux/tc_act/tc_ipt.h (100%)
 rename include/{ => uapi}/linux/tc_act/tc_mirred.h (100%)
 rename include/{ => uapi}/linux/tc_act/tc_nat.h (100%)
 rename include/{ => uapi}/linux/tc_act/tc_pedit.h (100%)
 rename include/{ => uapi}/linux/tc_act/tc_sample.h (100%)
 rename include/{ => uapi}/linux/tc_act/tc_skbedit.h (100%)
 rename include/{ => uapi}/linux/tc_act/tc_skbmod.h (100%)
 rename include/{ => uapi}/linux/tc_act/tc_tunnel_key.h (100%)
 rename include/{ => uapi}/linux/tc_act/tc_vlan.h (100%)
 rename include/{ => uapi}/linux/tc_ematch/tc_em_cmp.h (100%)
 rename include/{ => uapi}/linux/tc_ematch/tc_em_meta.h (100%)
 rename include/{ => uapi}/linux/tc_ematch/tc_em_nbyte.h (100%)
 rename include/{ => uapi}/linux/tcp.h (100%)
 rename include/{ => uapi}/linux/tcp_metrics.h (100%)
 rename include/{ => uapi}/linux/tipc.h (100%)
 rename include/{ => uapi}/linux/tipc_netlink.h (100%)
 rename include/{ => uapi}/linux/types.h (100%)
 rename include/{ => uapi}/linux/unix_diag.h (100%)
 rename include/{ => uapi}/linux/veth.h (100%)
 rename include/{ => uapi}/linux/xfrm.h (100%)

diff --git a/Makefile b/Makefile
index 75c0e57006..6ad9610430 100644
--- a/Makefile
+++ b/Makefile
@@ -46,7 +46,7 @@ CCOPTS = -O2
 WFLAGS := -Wall -Wstrict-prototypes  -Wmissing-prototypes
 WFLAGS += -Wmissing-declarations -Wold-style-definition -Wformat=2
 
-CFLAGS := $(WFLAGS) $(CCOPTS) -I../include $(DEFINES) $(CFLAGS)
+CFLAGS := $(WFLAGS) $(CCOPTS) -I../include -I../include/uapi $(DEFINES) $(CFLAGS)
 YACCFLAGS = -d -t -v
 
 SUBDIRS=lib ip tc bridge misc netem genl tipc devlink rdma man
diff --git a/include/linux/atm.h b/include/uapi/linux/atm.h
similarity index 100%
rename from include/linux/atm.h
rename to include/uapi/linux/atm.h
diff --git a/include/linux/atmapi.h b/include/uapi/linux/atmapi.h
similarity index 100%
rename from include/linux/atmapi.h
rename to include/uapi/linux/atmapi.h
diff --git a/include/linux/atmarp.h b/include/uapi/linux/atmarp.h
similarity index 100%
rename from include/linux/atmarp.h
rename to include/uapi/linux/atmarp.h
diff --git a/include/linux/atmdev.h b/include/uapi/linux/atmdev.h
similarity index 100%
rename from include/linux/atmdev.h
rename to include/uapi/linux/atmdev.h
diff --git a/include/linux/atmioc.h b/include/uapi/linux/atmioc.h
similarity index 100%
rename from include/linux/atmioc.h
rename to include/uapi/linux/atmioc.h
diff --git a/include/linux/atmsap.h b/include/uapi/linux/atmsap.h
similarity index 100%
rename from include/linux/atmsap.h
rename to include/uapi/linux/atmsap.h
diff --git a/include/linux/bpf.h b/include/uapi/linux/bpf.h
similarity index 100%
rename from include/linux/bpf.h
rename to include/uapi/linux/bpf.h
diff --git a/include/linux/bpf_common.h b/include/uapi/linux/bpf_common.h
similarity index 100%
rename from include/linux/bpf_common.h
rename to include/uapi/linux/bpf_common.h
diff --git a/include/linux/can.h b/include/uapi/linux/can.h
similarity index 100%
rename from include/linux/can.h
rename to include/uapi/linux/can.h
diff --git a/include/linux/can/netlink.h b/include/uapi/linux/can/netlink.h
similarity index 100%
rename from include/linux/can/netlink.h
rename to include/uapi/linux/can/netlink.h
diff --git a/include/linux/can/vxcan.h b/include/uapi/linux/can/vxcan.h
similarity index 100%
rename from include/linux/can/vxcan.h
rename to include/uapi/linux/can/vxcan.h
diff --git a/include/linux/devlink.h b/include/uapi/linux/devlink.h
similarity index 100%
rename from include/linux/devlink.h
rename to include/uapi/linux/devlink.h
diff --git a/include/linux/elf-em.h b/include/uapi/linux/elf-em.h
similarity index 100%
rename from include/linux/elf-em.h
rename to include/uapi/linux/elf-em.h
diff --git a/include/linux/fib_rules.h b/include/uapi/linux/fib_rules.h
similarity index 100%
rename from include/linux/fib_rules.h
rename to include/uapi/linux/fib_rules.h
diff --git a/include/linux/filter.h b/include/uapi/linux/filter.h
similarity index 100%
rename from include/linux/filter.h
rename to include/uapi/linux/filter.h
diff --git a/include/linux/fou.h b/include/uapi/linux/fou.h
similarity index 100%
rename from include/linux/fou.h
rename to include/uapi/linux/fou.h
diff --git a/include/linux/gen_stats.h b/include/uapi/linux/gen_stats.h
similarity index 100%
rename from include/linux/gen_stats.h
rename to include/uapi/linux/gen_stats.h
diff --git a/include/linux/genetlink.h b/include/uapi/linux/genetlink.h
similarity index 100%
rename from include/linux/genetlink.h
rename to include/uapi/linux/genetlink.h
diff --git a/include/linux/hdlc/ioctl.h b/include/uapi/linux/hdlc/ioctl.h
similarity index 100%
rename from include/linux/hdlc/ioctl.h
rename to include/uapi/linux/hdlc/ioctl.h
diff --git a/include/linux/icmpv6.h b/include/uapi/linux/icmpv6.h
similarity index 100%
rename from include/linux/icmpv6.h
rename to include/uapi/linux/icmpv6.h
diff --git a/include/linux/if.h b/include/uapi/linux/if.h
similarity index 100%
rename from include/linux/if.h
rename to include/uapi/linux/if.h
diff --git a/include/linux/if_addr.h b/include/uapi/linux/if_addr.h
similarity index 100%
rename from include/linux/if_addr.h
rename to include/uapi/linux/if_addr.h
diff --git a/include/linux/if_addrlabel.h b/include/uapi/linux/if_addrlabel.h
similarity index 100%
rename from include/linux/if_addrlabel.h
rename to include/uapi/linux/if_addrlabel.h
diff --git a/include/linux/if_alg.h b/include/uapi/linux/if_alg.h
similarity index 100%
rename from include/linux/if_alg.h
rename to include/uapi/linux/if_alg.h
diff --git a/include/linux/if_arp.h b/include/uapi/linux/if_arp.h
similarity index 100%
rename from include/linux/if_arp.h
rename to include/uapi/linux/if_arp.h
diff --git a/include/linux/if_bonding.h b/include/uapi/linux/if_bonding.h
similarity index 100%
rename from include/linux/if_bonding.h
rename to include/uapi/linux/if_bonding.h
diff --git a/include/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
similarity index 100%
rename from include/linux/if_bridge.h
rename to include/uapi/linux/if_bridge.h
diff --git a/include/linux/if_ether.h b/include/uapi/linux/if_ether.h
similarity index 100%
rename from include/linux/if_ether.h
rename to include/uapi/linux/if_ether.h
diff --git a/include/linux/if_link.h b/include/uapi/linux/if_link.h
similarity index 100%
rename from include/linux/if_link.h
rename to include/uapi/linux/if_link.h
diff --git a/include/linux/if_macsec.h b/include/uapi/linux/if_macsec.h
similarity index 100%
rename from include/linux/if_macsec.h
rename to include/uapi/linux/if_macsec.h
diff --git a/include/linux/if_packet.h b/include/uapi/linux/if_packet.h
similarity index 100%
rename from include/linux/if_packet.h
rename to include/uapi/linux/if_packet.h
diff --git a/include/linux/if_tun.h b/include/uapi/linux/if_tun.h
similarity index 100%
rename from include/linux/if_tun.h
rename to include/uapi/linux/if_tun.h
diff --git a/include/linux/if_tunnel.h b/include/uapi/linux/if_tunnel.h
similarity index 100%
rename from include/linux/if_tunnel.h
rename to include/uapi/linux/if_tunnel.h
diff --git a/include/linux/if_vlan.h b/include/uapi/linux/if_vlan.h
similarity index 100%
rename from include/linux/if_vlan.h
rename to include/uapi/linux/if_vlan.h
diff --git a/include/linux/ife.h b/include/uapi/linux/ife.h
similarity index 100%
rename from include/linux/ife.h
rename to include/uapi/linux/ife.h
diff --git a/include/linux/ila.h b/include/uapi/linux/ila.h
similarity index 100%
rename from include/linux/ila.h
rename to include/uapi/linux/ila.h
diff --git a/include/linux/in.h b/include/uapi/linux/in.h
similarity index 100%
rename from include/linux/in.h
rename to include/uapi/linux/in.h
diff --git a/include/linux/in6.h b/include/uapi/linux/in6.h
similarity index 100%
rename from include/linux/in6.h
rename to include/uapi/linux/in6.h
diff --git a/include/linux/in_route.h b/include/uapi/linux/in_route.h
similarity index 100%
rename from include/linux/in_route.h
rename to include/uapi/linux/in_route.h
diff --git a/include/linux/inet_diag.h b/include/uapi/linux/inet_diag.h
similarity index 100%
rename from include/linux/inet_diag.h
rename to include/uapi/linux/inet_diag.h
diff --git a/include/linux/ip.h b/include/uapi/linux/ip.h
similarity index 100%
rename from include/linux/ip.h
rename to include/uapi/linux/ip.h
diff --git a/include/linux/ip6_tunnel.h b/include/uapi/linux/ip6_tunnel.h
similarity index 100%
rename from include/linux/ip6_tunnel.h
rename to include/uapi/linux/ip6_tunnel.h
diff --git a/include/linux/ipsec.h b/include/uapi/linux/ipsec.h
similarity index 100%
rename from include/linux/ipsec.h
rename to include/uapi/linux/ipsec.h
diff --git a/include/linux/kernel.h b/include/uapi/linux/kernel.h
similarity index 100%
rename from include/linux/kernel.h
rename to include/uapi/linux/kernel.h
diff --git a/include/linux/l2tp.h b/include/uapi/linux/l2tp.h
similarity index 100%
rename from include/linux/l2tp.h
rename to include/uapi/linux/l2tp.h
diff --git a/include/linux/libc-compat.h b/include/uapi/linux/libc-compat.h
similarity index 100%
rename from include/linux/libc-compat.h
rename to include/uapi/linux/libc-compat.h
diff --git a/include/linux/limits.h b/include/uapi/linux/limits.h
similarity index 100%
rename from include/linux/limits.h
rename to include/uapi/linux/limits.h
diff --git a/include/linux/lwtunnel.h b/include/uapi/linux/lwtunnel.h
similarity index 100%
rename from include/linux/lwtunnel.h
rename to include/uapi/linux/lwtunnel.h
diff --git a/include/linux/magic.h b/include/uapi/linux/magic.h
similarity index 100%
rename from include/linux/magic.h
rename to include/uapi/linux/magic.h
diff --git a/include/linux/mpls.h b/include/uapi/linux/mpls.h
similarity index 100%
rename from include/linux/mpls.h
rename to include/uapi/linux/mpls.h
diff --git a/include/linux/mpls_iptunnel.h b/include/uapi/linux/mpls_iptunnel.h
similarity index 100%
rename from include/linux/mpls_iptunnel.h
rename to include/uapi/linux/mpls_iptunnel.h
diff --git a/include/linux/neighbour.h b/include/uapi/linux/neighbour.h
similarity index 100%
rename from include/linux/neighbour.h
rename to include/uapi/linux/neighbour.h
diff --git a/include/linux/net_namespace.h b/include/uapi/linux/net_namespace.h
similarity index 100%
rename from include/linux/net_namespace.h
rename to include/uapi/linux/net_namespace.h
diff --git a/include/linux/netconf.h b/include/uapi/linux/netconf.h
similarity index 100%
rename from include/linux/netconf.h
rename to include/uapi/linux/netconf.h
diff --git a/include/linux/netdevice.h b/include/uapi/linux/netdevice.h
similarity index 100%
rename from include/linux/netdevice.h
rename to include/uapi/linux/netdevice.h
diff --git a/include/linux/netfilter.h b/include/uapi/linux/netfilter.h
similarity index 100%
rename from include/linux/netfilter.h
rename to include/uapi/linux/netfilter.h
diff --git a/include/linux/netfilter/ipset/ip_set.h b/include/uapi/linux/netfilter/ipset/ip_set.h
similarity index 100%
rename from include/linux/netfilter/ipset/ip_set.h
rename to include/uapi/linux/netfilter/ipset/ip_set.h
diff --git a/include/linux/netfilter/x_tables.h b/include/uapi/linux/netfilter/x_tables.h
similarity index 100%
rename from include/linux/netfilter/x_tables.h
rename to include/uapi/linux/netfilter/x_tables.h
diff --git a/include/linux/netfilter/xt_set.h b/include/uapi/linux/netfilter/xt_set.h
similarity index 100%
rename from include/linux/netfilter/xt_set.h
rename to include/uapi/linux/netfilter/xt_set.h
diff --git a/include/linux/netfilter/xt_tcpudp.h b/include/uapi/linux/netfilter/xt_tcpudp.h
similarity index 100%
rename from include/linux/netfilter/xt_tcpudp.h
rename to include/uapi/linux/netfilter/xt_tcpudp.h
diff --git a/include/linux/netfilter_ipv4.h b/include/uapi/linux/netfilter_ipv4.h
similarity index 100%
rename from include/linux/netfilter_ipv4.h
rename to include/uapi/linux/netfilter_ipv4.h
diff --git a/include/linux/netfilter_ipv4/ip_tables.h b/include/uapi/linux/netfilter_ipv4/ip_tables.h
similarity index 100%
rename from include/linux/netfilter_ipv4/ip_tables.h
rename to include/uapi/linux/netfilter_ipv4/ip_tables.h
diff --git a/include/linux/netfilter_ipv6.h b/include/uapi/linux/netfilter_ipv6.h
similarity index 100%
rename from include/linux/netfilter_ipv6.h
rename to include/uapi/linux/netfilter_ipv6.h
diff --git a/include/linux/netfilter_ipv6/ip6_tables.h b/include/uapi/linux/netfilter_ipv6/ip6_tables.h
similarity index 100%
rename from include/linux/netfilter_ipv6/ip6_tables.h
rename to include/uapi/linux/netfilter_ipv6/ip6_tables.h
diff --git a/include/linux/netlink.h b/include/uapi/linux/netlink.h
similarity index 100%
rename from include/linux/netlink.h
rename to include/uapi/linux/netlink.h
diff --git a/include/linux/netlink_diag.h b/include/uapi/linux/netlink_diag.h
similarity index 100%
rename from include/linux/netlink_diag.h
rename to include/uapi/linux/netlink_diag.h
diff --git a/include/linux/packet_diag.h b/include/uapi/linux/packet_diag.h
similarity index 100%
rename from include/linux/packet_diag.h
rename to include/uapi/linux/packet_diag.h
diff --git a/include/linux/param.h b/include/uapi/linux/param.h
similarity index 100%
rename from include/linux/param.h
rename to include/uapi/linux/param.h
diff --git a/include/linux/pfkeyv2.h b/include/uapi/linux/pfkeyv2.h
similarity index 100%
rename from include/linux/pfkeyv2.h
rename to include/uapi/linux/pfkeyv2.h
diff --git a/include/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
similarity index 100%
rename from include/linux/pkt_cls.h
rename to include/uapi/linux/pkt_cls.h
diff --git a/include/linux/pkt_sched.h b/include/uapi/linux/pkt_sched.h
similarity index 100%
rename from include/linux/pkt_sched.h
rename to include/uapi/linux/pkt_sched.h
diff --git a/include/linux/posix_types.h b/include/uapi/linux/posix_types.h
similarity index 100%
rename from include/linux/posix_types.h
rename to include/uapi/linux/posix_types.h
diff --git a/include/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
similarity index 100%
rename from include/linux/rtnetlink.h
rename to include/uapi/linux/rtnetlink.h
diff --git a/include/linux/sctp.h b/include/uapi/linux/sctp.h
similarity index 100%
rename from include/linux/sctp.h
rename to include/uapi/linux/sctp.h
diff --git a/include/linux/seg6.h b/include/uapi/linux/seg6.h
similarity index 100%
rename from include/linux/seg6.h
rename to include/uapi/linux/seg6.h
diff --git a/include/linux/seg6_genl.h b/include/uapi/linux/seg6_genl.h
similarity index 100%
rename from include/linux/seg6_genl.h
rename to include/uapi/linux/seg6_genl.h
diff --git a/include/linux/seg6_hmac.h b/include/uapi/linux/seg6_hmac.h
similarity index 100%
rename from include/linux/seg6_hmac.h
rename to include/uapi/linux/seg6_hmac.h
diff --git a/include/linux/seg6_iptunnel.h b/include/uapi/linux/seg6_iptunnel.h
similarity index 100%
rename from include/linux/seg6_iptunnel.h
rename to include/uapi/linux/seg6_iptunnel.h
diff --git a/include/linux/seg6_local.h b/include/uapi/linux/seg6_local.h
similarity index 100%
rename from include/linux/seg6_local.h
rename to include/uapi/linux/seg6_local.h
diff --git a/include/linux/sock_diag.h b/include/uapi/linux/sock_diag.h
similarity index 100%
rename from include/linux/sock_diag.h
rename to include/uapi/linux/sock_diag.h
diff --git a/include/linux/socket.h b/include/uapi/linux/socket.h
similarity index 100%
rename from include/linux/socket.h
rename to include/uapi/linux/socket.h
diff --git a/include/linux/sockios.h b/include/uapi/linux/sockios.h
similarity index 100%
rename from include/linux/sockios.h
rename to include/uapi/linux/sockios.h
diff --git a/include/linux/stddef.h b/include/uapi/linux/stddef.h
similarity index 100%
rename from include/linux/stddef.h
rename to include/uapi/linux/stddef.h
diff --git a/include/linux/sysinfo.h b/include/uapi/linux/sysinfo.h
similarity index 100%
rename from include/linux/sysinfo.h
rename to include/uapi/linux/sysinfo.h
diff --git a/include/linux/tc_act/tc_bpf.h b/include/uapi/linux/tc_act/tc_bpf.h
similarity index 100%
rename from include/linux/tc_act/tc_bpf.h
rename to include/uapi/linux/tc_act/tc_bpf.h
diff --git a/include/linux/tc_act/tc_connmark.h b/include/uapi/linux/tc_act/tc_connmark.h
similarity index 100%
rename from include/linux/tc_act/tc_connmark.h
rename to include/uapi/linux/tc_act/tc_connmark.h
diff --git a/include/linux/tc_act/tc_csum.h b/include/uapi/linux/tc_act/tc_csum.h
similarity index 100%
rename from include/linux/tc_act/tc_csum.h
rename to include/uapi/linux/tc_act/tc_csum.h
diff --git a/include/linux/tc_act/tc_defact.h b/include/uapi/linux/tc_act/tc_defact.h
similarity index 100%
rename from include/linux/tc_act/tc_defact.h
rename to include/uapi/linux/tc_act/tc_defact.h
diff --git a/include/linux/tc_act/tc_gact.h b/include/uapi/linux/tc_act/tc_gact.h
similarity index 100%
rename from include/linux/tc_act/tc_gact.h
rename to include/uapi/linux/tc_act/tc_gact.h
diff --git a/include/linux/tc_act/tc_ife.h b/include/uapi/linux/tc_act/tc_ife.h
similarity index 100%
rename from include/linux/tc_act/tc_ife.h
rename to include/uapi/linux/tc_act/tc_ife.h
diff --git a/include/linux/tc_act/tc_ipt.h b/include/uapi/linux/tc_act/tc_ipt.h
similarity index 100%
rename from include/linux/tc_act/tc_ipt.h
rename to include/uapi/linux/tc_act/tc_ipt.h
diff --git a/include/linux/tc_act/tc_mirred.h b/include/uapi/linux/tc_act/tc_mirred.h
similarity index 100%
rename from include/linux/tc_act/tc_mirred.h
rename to include/uapi/linux/tc_act/tc_mirred.h
diff --git a/include/linux/tc_act/tc_nat.h b/include/uapi/linux/tc_act/tc_nat.h
similarity index 100%
rename from include/linux/tc_act/tc_nat.h
rename to include/uapi/linux/tc_act/tc_nat.h
diff --git a/include/linux/tc_act/tc_pedit.h b/include/uapi/linux/tc_act/tc_pedit.h
similarity index 100%
rename from include/linux/tc_act/tc_pedit.h
rename to include/uapi/linux/tc_act/tc_pedit.h
diff --git a/include/linux/tc_act/tc_sample.h b/include/uapi/linux/tc_act/tc_sample.h
similarity index 100%
rename from include/linux/tc_act/tc_sample.h
rename to include/uapi/linux/tc_act/tc_sample.h
diff --git a/include/linux/tc_act/tc_skbedit.h b/include/uapi/linux/tc_act/tc_skbedit.h
similarity index 100%
rename from include/linux/tc_act/tc_skbedit.h
rename to include/uapi/linux/tc_act/tc_skbedit.h
diff --git a/include/linux/tc_act/tc_skbmod.h b/include/uapi/linux/tc_act/tc_skbmod.h
similarity index 100%
rename from include/linux/tc_act/tc_skbmod.h
rename to include/uapi/linux/tc_act/tc_skbmod.h
diff --git a/include/linux/tc_act/tc_tunnel_key.h b/include/uapi/linux/tc_act/tc_tunnel_key.h
similarity index 100%
rename from include/linux/tc_act/tc_tunnel_key.h
rename to include/uapi/linux/tc_act/tc_tunnel_key.h
diff --git a/include/linux/tc_act/tc_vlan.h b/include/uapi/linux/tc_act/tc_vlan.h
similarity index 100%
rename from include/linux/tc_act/tc_vlan.h
rename to include/uapi/linux/tc_act/tc_vlan.h
diff --git a/include/linux/tc_ematch/tc_em_cmp.h b/include/uapi/linux/tc_ematch/tc_em_cmp.h
similarity index 100%
rename from include/linux/tc_ematch/tc_em_cmp.h
rename to include/uapi/linux/tc_ematch/tc_em_cmp.h
diff --git a/include/linux/tc_ematch/tc_em_meta.h b/include/uapi/linux/tc_ematch/tc_em_meta.h
similarity index 100%
rename from include/linux/tc_ematch/tc_em_meta.h
rename to include/uapi/linux/tc_ematch/tc_em_meta.h
diff --git a/include/linux/tc_ematch/tc_em_nbyte.h b/include/uapi/linux/tc_ematch/tc_em_nbyte.h
similarity index 100%
rename from include/linux/tc_ematch/tc_em_nbyte.h
rename to include/uapi/linux/tc_ematch/tc_em_nbyte.h
diff --git a/include/linux/tcp.h b/include/uapi/linux/tcp.h
similarity index 100%
rename from include/linux/tcp.h
rename to include/uapi/linux/tcp.h
diff --git a/include/linux/tcp_metrics.h b/include/uapi/linux/tcp_metrics.h
similarity index 100%
rename from include/linux/tcp_metrics.h
rename to include/uapi/linux/tcp_metrics.h
diff --git a/include/linux/tipc.h b/include/uapi/linux/tipc.h
similarity index 100%
rename from include/linux/tipc.h
rename to include/uapi/linux/tipc.h
diff --git a/include/linux/tipc_netlink.h b/include/uapi/linux/tipc_netlink.h
similarity index 100%
rename from include/linux/tipc_netlink.h
rename to include/uapi/linux/tipc_netlink.h
diff --git a/include/linux/types.h b/include/uapi/linux/types.h
similarity index 100%
rename from include/linux/types.h
rename to include/uapi/linux/types.h
diff --git a/include/linux/unix_diag.h b/include/uapi/linux/unix_diag.h
similarity index 100%
rename from include/linux/unix_diag.h
rename to include/uapi/linux/unix_diag.h
diff --git a/include/linux/veth.h b/include/uapi/linux/veth.h
similarity index 100%
rename from include/linux/veth.h
rename to include/uapi/linux/veth.h
diff --git a/include/linux/xfrm.h b/include/uapi/linux/xfrm.h
similarity index 100%
rename from include/linux/xfrm.h
rename to include/uapi/linux/xfrm.h
-- 
2.14.2.822.g60be5d43e6-goog
