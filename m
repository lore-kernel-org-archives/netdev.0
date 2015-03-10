From: Andy Zhou <azhou@nicira.com>
Subject: [patch net-next v2 0/5] Refactor IP defragmentation and fragmenation APIs for OVS conntrack support
Date: Tue, 10 Mar 2015 12:07:13 -0700
Message-ID: <1426014438-9317-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog127.obsmtp.com ([74.125.149.107]:40584 "HELO
	na3sys009aog127.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751330AbbCJTQh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 15:16:37 -0400
Received: by mail-pd0-f178.google.com with SMTP id nh10so4544608pdb.4
        for <netdev@vger.kernel.org>; Tue, 10 Mar 2015 12:16:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These are the patches refactors the core APIs for both IPv4 and IPv6.

The intended use for openvswitch has been posted in the eariler RFC:

http://lists.openwall.net/netdev/2015/03/02/220

Andy Zhou (5):
  net: add 'const' to __ipv6_select_ident()'s input address parameter
  net: add ipv6_select_ident_by_addr() API
  net: refactor IPv4 and IPv6 fragmentation APIs
  net: refactor IPv4 and IPv6 defragmentation APIs
  net: export symbol nf_ct_frag6_consume_orig

 include/net/ip.h                            |   7 +-
 include/net/ip6_route.h                     |   3 +-
 include/net/ipv6.h                          |   9 +-
 include/net/netfilter/ipv6/nf_defrag_ipv6.h |   2 +
 net/bridge/br_netfilter.c                   |   7 +-
 net/ipv4/ip_fragment.c                      |  15 ++-
 net/ipv4/ip_output.c                        | 126 ++++++++++++---------
 net/ipv6/ip6_output.c                       | 165 +++++++++++++++++-----------
 net/ipv6/netfilter/nf_conntrack_reasm.c     |  18 ++-
 net/ipv6/output_core.c                      |  18 ++-
 net/ipv6/xfrm6_output.c                     |   9 +-
 11 files changed, 242 insertions(+), 137 deletions(-)

-- 
v1->v2: change both ip_fragment() and ip6_fragment()'s output callback
        functions to take two arguments, skb and an output argument.

	split exporting nf_cf_frag6_consume_orig into its own patch. 

	fix style issues

1.9.1
