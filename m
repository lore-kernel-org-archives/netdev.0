From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 0/3] net: Pass net into defragmentation
Date: Fri, 09 Oct 2015 13:42:20 -0500
Message-ID: <87fv1jyjcj.fsf_-_@x220.int.ebiederm.org>
References: <87mvwn18my.fsf@x220.int.ebiederm.org>
	<87pp1fpy1b.fsf@x220.int.ebiederm.org>
	<87fv2bo7br.fsf_-_@x220.int.ebiederm.org>
	<87si62gteh.fsf_-_@x220.int.ebiederm.org>
	<877fn7eh2f.fsf_-_@x220.int.ebiederm.org>
	<878u7fesrg.fsf_-_@x220.int.ebiederm.org>
	<87bnca4aie.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:58990 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933629AbbJISty (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2015 14:49:54 -0400
In-Reply-To: <87bnca4aie.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Wed, 07 Oct 2015 16:46:49 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is the next installment of my work to pass struct net through the
output path so the code does not need to guess how to figure out which
network namespace it is in, and ultimately routes can have output
devices in another network namespace.

In netfilter and af_packet we defragment packets in the output path,
and there is the usual amount of confusion about how to compute which
net we are processing the packets in.  This patchset clears that
confusion up by explicitly passing in struct net in ip_defrag,
ip_check_defrag, and nf_ct_frag6_gather.

The changes are also available against net-next at:
git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/net-next.git master

Eric

Eric W. Biederman (3):
      ipv4: Only compute net once in ip_call_ra_chain
      ipv4: Pass struct net into ip_defrag and ip_check_defrag
      ipv6: Pass struct net into nf_ct_frag6_gather

 drivers/net/macvlan.c                       |  2 +-
 include/net/ip.h                            |  6 +++---
 include/net/netfilter/ipv6/nf_defrag_ipv6.h |  2 +-
 net/ipv4/ip_fragment.c                      |  7 +++----
 net/ipv4/ip_input.c                         | 10 ++++++----
 net/ipv4/netfilter/nf_defrag_ipv4.c         |  7 ++++---
 net/ipv6/netfilter/nf_conntrack_reasm.c     |  4 +---
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c   |  3 ++-
 net/netfilter/ipvs/ip_vs_core.c             |  2 +-
 net/openvswitch/conntrack.c                 |  4 ++--
 net/packet/af_packet.c                      |  6 +++---
 11 files changed, 27 insertions(+), 26 deletions(-)
