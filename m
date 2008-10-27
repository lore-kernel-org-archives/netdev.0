From: hamid.jafarian@gmail.com (hamid jafarian)
Subject: [PATCH 00/09]IPtablestng/Kernel - New Framework For IPtables
Date: Mon, 27 Oct 2008 07:58:33 +0330 (IRST)
Message-ID: <20081027042834.0BA69C64087@host1.ystp.ac.ir>
Cc: Netdev <netdev@vger.kernel.org>
To: Netfilter-devel <netfilter-devel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
cc: Pablo Neira Ayuso <pablo@netfilter.org>
cc: Patrick McHardy <kaber@trash.net>
cc: Jan Engelhardt <jengelh@medozas.de>
cc: David Miller <davem@davemloft.net>
cc: Rusty Russell <rusty@rustcorp.com.au>
cc: Harald Welte <laforge@gnumonks.org>
cc: Eric Leblond <eric@inl.fr>
cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
cc: Amin Azez <azez@ufomechanic.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

New Framework for IPtables

beside some powerfull & usefull features of iptables, this framework add this new features to the Iptables:
	1- Use link list for rule storage instead of continues memory.
	2- Move management activities to the kernel side. 
	3- Command base communication between Kernel/User spaces.
	4- New semantics & structures:
		4-1: tables as builtin/userdefined chains container: store them in link list
		4-2: chains as entry container: store them in link list
		4-3: ...
	5- Classifiers as search engine in chains instead of linear search:
			In This Version the Implementation of Classification algorithms Is like of Matches and Targets but doesn.t have User Space implementation. Every chain can use its classifier.
			By this ability (use/implement different classification algorithms), developers/administrators can classify their network packet flows in defferent ways base on the packet types or their needs and also more quickly than before.
	6- Common implementation for all of the tables of different network families(as pkt_tables) instead of copy based code.
	7- ...

this implementation is for kernel 2.6.25 and supports IPv4. 

patch summary:
 A  include/linux/netfilter/pkt_tables.h
 M  include/linux/netfilter/x_tables.h
 M  include/linux/netfilter_ipv4/ip_tables.h
 A  include/linux/netfilter_ipv4/ipc_tuple.h
 M  net/ipv4/netfilter/Kconfig
 M  net/ipv4/netfilter/Makefile
 M  net/ipv4/netfilter/ip_tables.c
 A  net/ipv4/netfilter/ipc_tuple.c
 M  net/ipv4/netfilter/ipt_CLUSTERIP.c
 M  net/ipv4/netfilter/ipt_ECN.c
 M  net/ipv4/netfilter/ipt_REJECT.c
 M  net/ipv4/netfilter/iptable_filter.c
 M  net/ipv4/netfilter/iptable_mangle.c
 M  net/ipv4/netfilter/iptable_raw.c
 M  net/ipv4/netfilter/nf_nat_rule.c
 M  net/netfilter/Kconfig
 M  net/netfilter/Makefile
 A  net/netfilter/pkt_tables.c
 M  net/netfilter/x_tables.c
 
 include/linux/netfilter/pkt_tables.h     |  542 +++++++
 include/linux/netfilter/x_tables.h       |   15 +
 include/linux/netfilter_ipv4/ip_tables.h |  231 +---
 include/linux/netfilter_ipv4/ipc_tuple.h |   69 +
 net/ipv4/netfilter/Kconfig               |   13 +
 net/ipv4/netfilter/Makefile              |    3 +
 net/ipv4/netfilter/ip_tables.c           | 2356 +++---------------------------
 net/ipv4/netfilter/ipc_tuple.c           |  300 ++++
 net/ipv4/netfilter/ipt_CLUSTERIP.c       |   16 +-
 net/ipv4/netfilter/ipt_ECN.c             |    2 +-
 net/ipv4/netfilter/ipt_REJECT.c          |    4 +-
 net/ipv4/netfilter/iptable_filter.c      |   57 +-
 net/ipv4/netfilter/iptable_mangle.c      |   69 +-
 net/ipv4/netfilter/iptable_raw.c         |   55 +-
 net/ipv4/netfilter/nf_nat_rule.c         |   60 +-
 net/netfilter/Kconfig                    |    8 +
 net/netfilter/Makefile                   |    1 +
 net/netfilter/pkt_tables.c               | 2203 ++++++++++++++++++++++++++++
 net/netfilter/x_tables.c                 |   14 +-
 19 files changed, 3442 insertions(+), 2576 deletions(-)

