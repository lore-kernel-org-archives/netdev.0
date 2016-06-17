From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 0/3] Big C99 style initializer rework
Date: Fri, 17 Jun 2016 17:56:05 +0200
Message-ID: <1466178968-27439-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:49228 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755532AbcFQP4f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jun 2016 11:56:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first patch changes the code to use C99 style initializers where
applicable, mainly as an alternative to calling memset() and optionally
initializing individual fields afterwards.

The remaining patches contain some fallout from compiling the first one.

Phil Sutter (3):
  Use C99 style initializers everywhere
  Replace malloc && memset by calloc
  No need to initialize rtattr fields before parsing

 bridge/fdb.c       |  29 ++++++------
 bridge/link.c      |  16 +++----
 bridge/mdb.c       |  19 ++++----
 bridge/vlan.c      |  19 ++++----
 genl/ctrl.c        |  48 +++++++++-----------
 genl/genl.c        |   3 +-
 ip/ip6tunnel.c     |  10 ++---
 ip/ipaddress.c     |  33 ++++++--------
 ip/ipaddrlabel.c   |  23 +++++-----
 ip/iplink.c        |  67 +++++++++++++---------------
 ip/iplink_can.c    |   4 +-
 ip/ipmaddr.c       |  27 +++++------
 ip/ipmroute.c      |   8 +---
 ip/ipneigh.c       |  36 +++++++--------
 ip/ipnetconf.c     |  12 ++---
 ip/ipnetns.c       |  45 ++++++++++---------
 ip/ipntable.c      |  27 +++++------
 ip/iproute.c       |  85 +++++++++++++++--------------------
 ip/iprule.c        |  26 +++++------
 ip/iptoken.c       |  21 ++++-----
 ip/iptunnel.c      |  31 ++++---------
 ip/ipxfrm.c        |  26 +++--------
 ip/link_gre.c      |  22 ++++-----
 ip/link_gre6.c     |  22 ++++-----
 ip/link_ip6tnl.c   |  29 ++++++------
 ip/link_iptnl.c    |  26 +++++------
 ip/link_vti.c      |  22 ++++-----
 ip/link_vti6.c     |  22 ++++-----
 ip/xfrm_policy.c   | 110 +++++++++++++++++++++------------------------
 ip/xfrm_state.c    | 128 ++++++++++++++++++++++++++---------------------------
 lib/libnetlink.c   |  74 +++++++++++++------------------
 lib/ll_map.c       |   1 -
 lib/names.c        |   7 +--
 misc/arpd.c        |  68 ++++++++++++++--------------
 misc/lnstat.c      |   6 +--
 misc/lnstat_util.c |   4 +-
 misc/ss.c          |  41 ++++++++---------
 tc/e_bpf.c         |   7 +--
 tc/em_canid.c      |   3 +-
 tc/em_cmp.c        |   4 +-
 tc/em_ipset.c      |   4 +-
 tc/em_meta.c       |   4 +-
 tc/em_nbyte.c      |   4 +-
 tc/em_u32.c        |   4 +-
 tc/f_flow.c        |   3 --
 tc/f_flower.c      |   3 +-
 tc/f_fw.c          |   6 +--
 tc/f_route.c       |   3 --
 tc/f_rsvp.c        |   6 +--
 tc/f_u32.c         |  12 ++---
 tc/m_action.c      |  54 +++++++++-------------
 tc/m_bpf.c         |   5 +--
 tc/m_csum.c        |   4 +-
 tc/m_ematch.c      |   4 +-
 tc/m_gact.c        |   5 +--
 tc/m_ife.c         |   5 +--
 tc/m_ipt.c         |  13 ++----
 tc/m_mirred.c      |   7 +--
 tc/m_nat.c         |   4 +-
 tc/m_pedit.c       |  11 ++---
 tc/m_police.c      |   5 +--
 tc/q_atm.c         |   3 +-
 tc/q_cbq.c         |  22 +++------
 tc/q_choke.c       |   4 +-
 tc/q_codel.c       |   3 +-
 tc/q_dsmark.c      |   1 -
 tc/q_fifo.c        |   4 +-
 tc/q_fq_codel.c    |   3 +-
 tc/q_hfsc.c        |  13 ++----
 tc/q_htb.c         |  15 +++----
 tc/q_netem.c       |  16 +++----
 tc/q_red.c         |   4 +-
 tc/q_sfb.c         |  17 ++++---
 tc/q_sfq.c         |   4 +-
 tc/q_tbf.c         |   4 +-
 tc/tc.c            |   9 ++--
 tc/tc_bpf.c        | 100 +++++++++++++++++------------------------
 tc/tc_class.c      |  40 +++++++----------
 tc/tc_exec.c       |   6 +--
 tc/tc_filter.c     |  35 ++++++---------
 tc/tc_qdisc.c      |  35 ++++++---------
 tc/tc_stab.c       |   4 +-
 tc/tc_util.c       |   3 +-
 83 files changed, 721 insertions(+), 1001 deletions(-)

-- 
2.8.2
