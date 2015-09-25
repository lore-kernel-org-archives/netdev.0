From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH next 0/5] netfilter: Pass net into ip_route_me_harder
Date: Fri, 25 Sep 2015 15:01:42 -0500
Message-ID: <87si62gteh.fsf_-_@x220.int.ebiederm.org>
References: <87mvwn18my.fsf@x220.int.ebiederm.org>
	<87pp1fpy1b.fsf@x220.int.ebiederm.org>
	<87fv2bo7br.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	David Miller <davem@davemloft.net>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87fv2bo7br.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Fri, 18 Sep 2015 14:28:40 -0500")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This is the next installment of my work to pass struct net through the
output path so the code does not need to guess how to figure out which
network namespace it is in, and ultimately routes can have output
devices in another network namespace.

This round the focus is our getting struct net passed in, instead of
guess in the netfilter functions that reroute packets
(ip_route_me_harder, and ip6_route_me_harder).  There is a bit more work
on the ipv4 side as the ipv6 code on several of these code paths already
passes in the struct net.

The changes are also available against nf-next at:
git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/net-next.git master

My entire pending set of changes for those who want to look ahead is at:
git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/net-next.git for-testing

Eric

Eric W. Biederman (5):
      ipv4: Push struct net down into nf_send_reset
      netfilter: Push struct net down into nf_afinfo.reroute
      netfilter: ipt_SYNPROXY: Pass snet into synproxy_send_tcp
      ipv4: Pass struct net into ip_route_me_harder
      ipv6: Pass struct net into ip6_route_me_harder

 include/linux/netfilter.h                 |  2 +-
 include/linux/netfilter_ipv4.h            |  2 +-
 include/linux/netfilter_ipv6.h            |  2 +-
 include/net/netfilter/ipv4/nf_reject.h    |  2 +-
 net/ipv4/netfilter.c                      |  7 +++----
 net/ipv4/netfilter/ipt_REJECT.c           |  2 +-
 net/ipv4/netfilter/ipt_SYNPROXY.c         | 20 ++++++++++++--------
 net/ipv4/netfilter/iptable_mangle.c       |  2 +-
 net/ipv4/netfilter/nf_nat_l3proto_ipv4.c  |  2 +-
 net/ipv4/netfilter/nf_reject_ipv4.c       |  4 ++--
 net/ipv4/netfilter/nft_chain_route_ipv4.c |  2 +-
 net/ipv4/netfilter/nft_reject_ipv4.c      |  2 +-
 net/ipv6/netfilter.c                      |  7 +++----
 net/ipv6/netfilter/ip6table_mangle.c      |  2 +-
 net/ipv6/netfilter/nf_nat_l3proto_ipv6.c  |  2 +-
 net/ipv6/netfilter/nft_chain_route_ipv6.c |  2 +-
 net/netfilter/ipvs/ip_vs_core.c           |  4 ++--
 net/netfilter/nf_queue.c                  |  2 +-
 net/netfilter/nft_reject_inet.c           |  2 +-
 19 files changed, 36 insertions(+), 34 deletions(-)
