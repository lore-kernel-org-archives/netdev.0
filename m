From: Joe Perches <joe@perches.com>
Subject: [RFC patch net/next] net: Hoist assigns from if?
Date: Mon, 14 Jun 2010 17:20:34 -0700
Message-ID: <1276561234.4897.38.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1133 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756540Ab0FOAUg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jun 2010 20:20:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Awhile back I posted a script to reformat source code,
similar to Lindent, but able to select in a piecemeal
manner what source code style to convert.

http://lkml.org/lkml/2010/3/24/447

One of the options is to convert code from:
	if ((err = function(args)) != NULL) {
to:
	err = function(args);
	if (err != NULL) {

I ran this script against net/ and get this result:

$ grep -rPl --include=*.[ch] "\bif\s*\(\s*\(" net/ | \
  grep -v netfilter | \
  xargs ./scripts/cvt_kernel_style.pl -o -convert=hoist_assigns_from_if 

and after a little cleanup, compilation verification, etc
I get the diffstat below.  Should I post the actual patch?

 net/802/tr.c                            |    3 +-
 net/appletalk/ddp.c                     |   15 +++++---
 net/ax25/af_ax25.c                      |   34 ++++++++++++------
 net/ax25/ax25_addr.c                    |    3 +-
 net/ax25/ax25_dev.c                     |   18 ++++++---
 net/ax25/ax25_ds_subr.c                 |    3 +-
 net/ax25/ax25_iface.c                   |    3 +-
 net/ax25/ax25_in.c                      |   12 ++++--
 net/ax25/ax25_ip.c                      |    9 +++--
 net/ax25/ax25_out.c                     |   21 +++++++----
 net/ax25/ax25_route.c                   |   27 +++++++++-----
 net/ax25/ax25_subr.c                    |    6 ++-
 net/ax25/ax25_uid.c                     |    3 +-
 net/ax25/sysctl_net_ax25.c              |    3 +-
 net/bluetooth/cmtp/capi.c               |    3 +-
 net/bluetooth/cmtp/core.c               |    9 +++--
 net/bluetooth/hci_conn.c                |   21 +++++++----
 net/bluetooth/hci_core.c                |   45 ++++++++++++++++--------
 net/bluetooth/hci_event.c               |   18 ++++++---
 net/bluetooth/hci_sock.c                |   15 +++++---
 net/bluetooth/rfcomm/sock.c             |    3 +-
 net/bluetooth/rfcomm/tty.c              |   15 +++++---
 net/bluetooth/sco.c                     |   15 +++++---
 net/bridge/br_ioctl.c                   |    9 +++--
 net/core/datagram.c                     |   24 ++++++++----
 net/core/net-sysfs.c                    |    3 +-
 net/core/netpoll.c                      |   30 +++++++++++-----
 net/core/skbuff.c                       |   36 +++++++++++++------
 net/dccp/ccids/ccid3.c                  |    3 +-
 net/dccp/ipv4.c                         |    3 +-
 net/dccp/proto.c                        |    6 ++-
 net/decnet/af_decnet.c                  |    6 ++-
 net/decnet/dn_dev.c                     |   36 +++++++++++++------
 net/decnet/dn_fib.c                     |   15 +++++---
 net/decnet/dn_nsp_in.c                  |    6 ++-
 net/decnet/dn_nsp_out.c                 |   30 +++++++++++-----
 net/decnet/dn_route.c                   |   24 ++++++++----
 net/decnet/dn_table.c                   |    6 ++-
 net/econet/af_econet.c                  |   17 +++++----
 net/ipv4/ah4.c                          |    6 ++-
 net/ipv4/arp.c                          |   18 ++++++---
 net/ipv4/esp4.c                         |    6 ++-
 net/ipv4/fib_hash.c                     |    3 +-
 net/ipv4/fib_rules.c                    |    3 +-
 net/ipv4/fib_semantics.c                |   15 +++++---
 net/ipv4/ip_fragment.c                  |    6 ++-
 net/ipv4/ip_gre.c                       |   20 +++++++----
 net/ipv4/ip_input.c                     |    3 +-
 net/ipv4/ip_output.c                    |   21 +++++++----
 net/ipv4/ipconfig.c                     |   45 ++++++++++++++++--------
 net/ipv4/ipip.c                         |   20 +++++++----
 net/ipv4/ipmr.c                         |    9 +++--
 net/ipv4/route.c                        |    6 ++-
 net/ipv4/tcp.c                          |   24 ++++++++----
 net/ipv4/tcp_ipv4.c                     |    3 +-
 net/ipv4/tcp_minisocks.c                |    3 +-
 net/ipv4/tcp_output.c                   |    6 ++-
 net/ipv4/udp.c                          |    3 +-
 net/ipv6/addrconf.c                     |   12 ++++--
 net/ipv6/addrlabel.c                    |    8 +++--
 net/ipv6/af_inet6.c                     |   12 ++++--
 net/ipv6/ah6.c                          |    6 ++-
 net/ipv6/datagram.c                     |    3 +-
 net/ipv6/esp6.c                         |    6 ++-
 net/ipv6/icmp.c                         |    6 ++-
 net/ipv6/inet6_connection_sock.c        |    3 +-
 net/ipv6/ip6_input.c                    |    6 ++-
 net/ipv6/ip6_output.c                   |   18 ++++++---
 net/ipv6/ip6_tunnel.c                   |   23 +++++++-----
 net/ipv6/raw.c                          |    3 +-
 net/ipv6/reassembly.c                   |    3 +-
 net/ipv6/sit.c                          |   15 +++++---
 net/ipv6/tcp_ipv6.c                     |   12 ++++--
 net/ipv6/udp.c                          |    6 ++-
 net/ipx/af_ipx.c                        |    3 +-
 net/irda/af_irda.c                      |   12 ++++--
 net/irda/ircomm/ircomm_tty.c            |    3 +-
 net/irda/irlap_frame.c                  |    6 ++-
 net/irda/irnet/irnet_irda.c             |    6 ++-
 net/irda/irqueue.c                      |    3 +-
 net/key/af_key.c                        |   42 +++++++++++++++-------
 net/lapb/lapb_out.c                     |    3 +-
 net/lapb/lapb_subr.c                    |    6 ++-
 net/netrom/af_netrom.c                  |   24 ++++++++----
 net/netrom/nr_in.c                      |    3 +-
 net/netrom/nr_loopback.c                |    6 ++-
 net/netrom/nr_out.c                     |   12 ++++--
 net/netrom/nr_route.c                   |   30 +++++++++++-----
 net/netrom/nr_subr.c                    |    6 ++-
 net/packet/af_packet.c                  |    3 +-
 net/rose/af_rose.c                      |   21 +++++++----
 net/rose/rose_dev.c                     |    3 +-
 net/rose/rose_link.c                    |    9 +++--
 net/rose/rose_loopback.c                |    3 +-
 net/rose/rose_out.c                     |    3 +-
 net/rose/rose_route.c                   |   39 ++++++++++++++-------
 net/rose/rose_subr.c                    |    3 +-
 net/sched/act_api.c                     |    3 +-
 net/sched/act_ipt.c                     |    3 +-
 net/sched/cls_api.c                     |    9 +++--
 net/sched/cls_route.c                   |   21 +++++++----
 net/sched/cls_rsvp.h                    |    6 ++-
 net/sched/cls_u32.c                     |    3 +-
 net/sched/sch_api.c                     |   30 +++++++++++-----
 net/sched/sch_cbq.c                     |   33 +++++++++++------
 net/sched/sch_gred.c                    |    3 +-
 net/sched/sch_hfsc.c                    |   12 ++++--
 net/sched/sch_htb.c                     |   24 ++++++++----
 net/sched/sch_prio.c                    |    3 +-
 net/sched/sch_teql.c                    |    9 +++--
 net/sctp/input.c                        |    3 +-
 net/sctp/inqueue.c                      |    3 +-
 net/sctp/ipv6.c                         |    3 +-
 net/sctp/protocol.c                     |    6 ++-
 net/sctp/sm_make_chunk.c                |    3 +-
 net/sctp/socket.c                       |    4 +-
 net/sunrpc/auth.c                       |    9 +++--
 net/sunrpc/auth_gss/auth_gss.c          |    9 +++--
 net/sunrpc/auth_gss/gss_generic_token.c |   20 +++++++----
 net/sunrpc/auth_gss/gss_krb5_seqnum.c   |    3 +-
 net/sunrpc/auth_gss/gss_mech_switch.c   |    3 +-
 net/sunrpc/auth_gss/gss_spkm3_token.c   |    3 +-
 net/sunrpc/auth_gss/gss_spkm3_unseal.c  |    3 +-
 net/sunrpc/clnt.c                       |    9 +++--
 net/sunrpc/svcsock.c                    |   17 ++++++---
 net/sunrpc/xdr.c                        |    3 +-
 net/sunrpc/xprtsock.c                   |   18 ++++++---
 net/tipc/bearer.c                       |    3 +-
 net/tipc/core.c                         |    3 +-
 net/tipc/link.c                         |   15 +++++---
 net/tipc/net.c                          |    3 +-
 net/tipc/socket.c                       |   18 ++++++---
 net/tipc/user_reg.c                     |    3 +-
 net/wireless/wext-core.c                |    3 +-
 net/x25/af_x25.c                        |    9 +++--
 net/x25/x25_dev.c                       |    6 ++-
 net/x25/x25_forward.c                   |   21 +++++++----
 net/x25/x25_in.c                        |    3 +-
 net/x25/x25_link.c                      |    6 ++-
 net/x25/x25_out.c                       |   10 +++--
 net/x25/x25_subr.c                      |    3 +-
 net/xfrm/xfrm_policy.c                  |   21 +++++++----
 net/xfrm/xfrm_state.c                   |    3 +-
 net/xfrm/xfrm_user.c                    |   58 ++++++++++++++----------------
 144 files changed, 1071 insertions(+), 564 deletions(-)



