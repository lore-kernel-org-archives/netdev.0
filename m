From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/90] Netfilter/IPVS updates for net-next
Date: Tue, 29 Sep 2015 21:25:21 +0200
Message-ID: <1443554721-11554-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:46699 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965153AbbI2TSe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Sep 2015 15:18:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following pull request contains Netfilter/IPVS updates for net-next
containing 90 patches from Eric Biederman.

The main goal of this batch is to avoid recurrent lookups for the netns
pointer, that happens over and over again in our Netfilter/IPVS code. The idea
consists of passing netns pointer from the hook state to the relevant functions
and objects where this may be needed.

You can find more information on the IPVS updates from Simon Horman's commit
merge message:

c3456026adc0 ("Merge tag 'ipvs2-for-v4.4' of https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next").

Exceptionally, this time, I'm not posting the patches again on netdev, Eric
already Cc'ed this mailing list in the original submission. If you need me to
make, just let me know.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Thanks!

----------------------------------------------------------------

The following changes since commit aee2f545f0a12399cc6bbe134d69b8994582b694:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue (2015-09-24 15:39:09 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git HEAD

for you to fetch changes up to c1444c6357217cea405415b4c96491d4057b0746:

  bridge: Pass net into br_validate_ipv4 and br_validate_ipv6 (2015-09-29 20:21:32 +0200)

----------------------------------------------------------------
Eric W. Biederman (90):
      ipvs: Hoist computation of ipvs earlier in sctp_conn_schedule
      ipvs: Don't use current in proc_do_defense_mode
      ipvs: Use state->net in the ipvs forward functions
      ipvs: Store ipvs not net in struct ip_vs_conn
      ipvs: Store ipvs not net in struct ip_vs_conn_param
      ipvs: Pass ipvs not net to ip_vs_fill_conn
      ipvs: Store ipvs not net in struct ip_vs_service
      ipvs: Pass ipvs not net to ip_vs_svc_fwm_hashkey
      ipvs: Pass ipvs not net to __ip_vs_svc_fwm_find
      ipvs: Pass ipvs not net to ip_vs_svc_hashkey
      ipvs: Pass ipvs not net to __ip_vs_service_find
      ipvs: Pass ipvs not net to ip_vs_service_find
      ipvs: Pass ipvs not net to ip_vs_has_real_service
      ipvs: Pass ipvs not net to ip_vs_find_dest
      ipvs: Pass ipvs not net to ip_vs_trash_cleanup
      ipvs: Pass ipvs not net to __ip_vs_del_dest
      ipvs: Pass ipvs not net to ip_vs_dest_trash_expire
      ipvs: Cache ipvs in ip_vs_genl_set_cmd
      ipvs: Pass ipvs not net to ip_vs_add_service
      ipvs: Pass ipvs not net to ip_vs_flush
      ipvs: Pass ipvs not net to ip_vs_service_net_cleanup
      ipvs: Pass ipvs not net to ip_vs_zero_all
      ipvs: Cache ipvs in ip_vs_in_icmp and ip_vs_in_icmp_v6
      ipvs: Pass ipvs not net to ip_vs_proto_data_get
      ipvs: Pass ipvs not net to ip_vs_set_timeout
      ipvs: Pass ipvs not net to __ip_vs_get_service_entries
      ipvs: Pass ipvs not net to __ip_vs_get_dest_entries
      ipvs: Pass ipvs not net to __ip_vs_get_timeouts
      ipvs: Pass ipvs not net to ip_vs_genl_parse_service
      ipvs: Pass ipvs not net to ip_vs_genl_find_service
      ipvs: Pass ipvs not net to ip_vs_genl_new_daemon
      ipvs: Pass ipvs not net to ip_vs_genl_del_daemon
      ipvs: Pass ipvs not net to start_sync_thread
      ipvs: Pass ipvs not net to stop_sync_thread
      ipvs: Pass ipvs not net to make_send_sock
      ipvs: Pass ipvs not net to make_receive_sock
      ipvs: Store ipvs not net in struct ip_vs_sync_thread_data
      ipvs: Pass ipvs not net to ip_vs_process_message
      ipvs: Pass ipvs not net to ip_vs_sync_conn_v0
      ipvs: Pass ipvs not net to ip_vs_sync_conn
      ipvs: Pass ipvs not net to ip_vs_proc_conn
      ipvs: Pass ipvs not net to ip_vs_proc_sync_conn
      ipvs: Pass ipvs not net to ip_vs_sync_net_init
      ipvs: Pass ipvs not net to ip_vs_sync_net_cleanup
      ipvs: Pass ipvs not net to ip_vs_genl_set_config
      ipvs: Pass ipvs not net to ip_vs_start_estimator aned ip_vs_stop_estimator
      ipvs: Pass ipvs not net to ip_vs_random_drop_entry
      ipvs: Pass ipvs not net to ip_vs_control_net_(init|cleanup)_sysctl
      ipvs: Pass ipvs not net into ip_vs_control_net_(init|cleanup)
      ipvs: Pass ipvs not net to estimation_timer
      ipvs: Pass ipvs not net to ip_vs_estimator_net_init and ip_vs_estimator_cleanup
      ipvs: Pass ipvs not net into register_app and unregister_app
      ipvs: Pass ipvs not net into ip_vs_app_inc_new
      ipvs: Pass ipvs not net to register_ip_vs_app_inc
      ipvs: Pass ipvs not net to register_ip_vs_app and unregister_ip_vs_app
      ipvs: Pass ipvs not net into ip_vs_app_inc_release
      ipvs: Pass ipvs not net into ip_vs_app_net_init and ip_vs_app_net_cleanup
      ipvs: Pass ipvs not net into [un]register_ip_vs_proto_netns
      ipvs: Pass ipvs not net into init_netns and exit_netns
      ipvs: Pass ipvs into ip_vs_conn_fill_param_proto
      ipvs: Pass ipvs into .conn_in_get and ip_vs_conn_in_get_proto
      ipvs: Pass ipvs into conn_out_get
      ipvs: Pass ipvs not net to ip_vs_conn_hashkey
      ipvs: Pass ipvs not net into ip_vs_conn_net_flush
      ipvs: Pass ipvs not net into ip_vs_conn_net_init and ip_vs_conn_net_cleanup
      ipvs: Pass ipvs into .conn_schedule and ip_vs_try_to_schedule
      ipvs: Better derivation of ipvs in ip_vs_tunnel_xmit
      ipvs: Pass ipvs into __ip_vs_get_out_rt
      ipvs: Pass ipvs into __ip_vs_get_out_rt_v6
      ipvs: Pass ipvs into ensure_mtu_is adequate
      ipvs: Better derivation of ipvs in ip_vs_in_stats and ip_vs_out_stats
      ipvs: Wrap sysctl_cache_bypass and remove ifdefs in ip_vs_leave
      ipvs: Simplify ipvs and net access in ip_vs_leave
      ipvs: Pass ipvs not net into sysctl_nat_icmp_send
      ipvs: Pass ipvs into ip_vs_out
      ipvs: Pass ipvs into ip_vs_in
      ipvs: Pass ipvs into ip_vs_in_icmp and ip_vs_in_icmp_v6
      ipvs: Pass ipvs into ip_vs_out_icmp and ip_vs_out_icmp_v6
      ipvs: Pass ipvs through ip_vs_route_me_harder into sysctl_snat_reroute
      ipvs: Remove net argument from ip_vs_tcp_conn_listen
      ipvs: Pass ipvs not net to ip_vs_protocol_net_(init|cleanup)
      ipvs: Remove skb_net
      ipvs: Remove skb_sknet
      ipvs: Pass ipvs into ip_vs_gather_frags
      ipv4: Push struct net down into nf_send_reset
      netfilter: Push struct net down into nf_afinfo.reroute
      netfilter: ipt_SYNPROXY: Pass snet into synproxy_send_tcp
      ipv4: Pass struct net into ip_route_me_harder
      ipv6: Pass struct net into ip6_route_me_harder
      bridge: Pass net into br_validate_ipv4 and br_validate_ipv6

Pablo Neira Ayuso (1):
      Merge tag 'ipvs2-for-v4.4' of https://git.kernel.org/.../horms/ipvs-next

 include/linux/netfilter.h                 |   2 +-
 include/linux/netfilter_ipv4.h            |   2 +-
 include/linux/netfilter_ipv6.h            |   2 +-
 include/net/ip_vs.h                       | 179 ++++++-------------
 include/net/netfilter/br_netfilter.h      |   4 +-
 include/net/netfilter/ipv4/nf_reject.h    |   2 +-
 net/bridge/br_netfilter_hooks.c           |  19 +-
 net/bridge/br_netfilter_ipv6.c            |  11 +-
 net/ipv4/netfilter.c                      |   7 +-
 net/ipv4/netfilter/ipt_REJECT.c           |   2 +-
 net/ipv4/netfilter/ipt_SYNPROXY.c         |  20 ++-
 net/ipv4/netfilter/iptable_mangle.c       |   2 +-
 net/ipv4/netfilter/nf_nat_l3proto_ipv4.c  |   2 +-
 net/ipv4/netfilter/nf_reject_ipv4.c       |   4 +-
 net/ipv4/netfilter/nft_chain_route_ipv4.c |   2 +-
 net/ipv4/netfilter/nft_reject_ipv4.c      |   2 +-
 net/ipv6/netfilter.c                      |   7 +-
 net/ipv6/netfilter/ip6table_mangle.c      |   2 +-
 net/ipv6/netfilter/nf_nat_l3proto_ipv6.c  |   2 +-
 net/ipv6/netfilter/nft_chain_route_ipv6.c |   2 +-
 net/netfilter/ipvs/ip_vs_app.c            |  36 ++--
 net/netfilter/ipvs/ip_vs_conn.c           |  76 ++++----
 net/netfilter/ipvs/ip_vs_core.c           | 232 ++++++++++++-------------
 net/netfilter/ipvs/ip_vs_ctl.c            | 276 +++++++++++++++---------------
 net/netfilter/ipvs/ip_vs_est.c            |  20 +--
 net/netfilter/ipvs/ip_vs_ftp.c            |  27 +--
 net/netfilter/ipvs/ip_vs_lblc.c           |   3 +-
 net/netfilter/ipvs/ip_vs_lblcr.c          |   3 +-
 net/netfilter/ipvs/ip_vs_nfct.c           |   5 +-
 net/netfilter/ipvs/ip_vs_proto.c          |  33 ++--
 net/netfilter/ipvs/ip_vs_proto_ah_esp.c   |  19 +-
 net/netfilter/ipvs/ip_vs_proto_sctp.c     |  28 ++-
 net/netfilter/ipvs/ip_vs_proto_tcp.c      |  33 ++--
 net/netfilter/ipvs/ip_vs_proto_udp.c      |  28 ++-
 net/netfilter/ipvs/ip_vs_sync.c           |  87 ++++------
 net/netfilter/ipvs/ip_vs_xmit.c           |  55 +++---
 net/netfilter/nf_queue.c                  |   2 +-
 net/netfilter/nft_reject_inet.c           |   2 +-
 net/netfilter/xt_ipvs.c                   |   3 +-
 39 files changed, 553 insertions(+), 690 deletions(-)
