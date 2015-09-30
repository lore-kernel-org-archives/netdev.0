From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 0/6] net: Pass net through ip fragmention
Date: Wed, 30 Sep 2015 16:24:40 -0500
Message-ID: <877fn7eh2f.fsf_-_@x220.int.ebiederm.org>
References: <87mvwn18my.fsf@x220.int.ebiederm.org>
	<87pp1fpy1b.fsf@x220.int.ebiederm.org>
	<87fv2bo7br.fsf_-_@x220.int.ebiederm.org>
	<87si62gteh.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87si62gteh.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Fri, 25 Sep 2015 15:01:42 -0500")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This is the next installment of my work to pass struct net through the
output path so the code does not need to guess how to figure out which
network namespace it is in, and ultimately routes can have output
devices in another network namespace.

This round focuses on passing net through ip fragmentation which we seem
to call from about everywhere.  That is the main ip output paths, the
bridge netfilter code, and openvswitch.  This has to happend at once
accross the tree as function pointers are involved.

First some prep work is done, then ipv4 and ipv6 are converted and then
temporary helper functions are removed.

The changes are also available against nf-next at:
git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/net-next.git master

Eric

Eric W. Biederman (6):
      openvswitch: Pass net into ovs_vport_output
      openvswitch: Pass net into ovs_fragment
      ipv4: Pass struct net through ip_fragment
      ipv6: Pass struct net through ip6_fragment
      bridge: Remove br_nf_push_frag_xmit_sk
      openvswitch: Remove ovs_vport_output_sk

 include/linux/netfilter_ipv6.h  |  4 ++--
 include/net/ip.h                |  4 ++--
 include/net/ip6_route.h         |  4 ++--
 net/bridge/br_netfilter_hooks.c | 13 ++++--------
 net/ipv4/ip_output.c            | 44 +++++++++++++++++++----------------------
 net/ipv6/ip6_output.c           | 16 +++++++--------
 net/ipv6/xfrm6_output.c         | 10 ++++++++--
 net/openvswitch/actions.c       | 13 ++++++------
 8 files changed, 52 insertions(+), 56 deletions(-)
