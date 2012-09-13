From: pablo@netfilter.org
Subject: [PATCH 0/4] netfilter updates for 3.6-rc5
Date: Thu, 13 Sep 2012 12:54:04 +0200
Message-ID: <1347533648-3451-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi David,

The following patchset contains four updates for your net tree, they are:

* Fix crash on timewait sockets, since the TCP early demux was added,
  in nfnetlink_log, from Eric Dumazet.

* Fix broken syslog log-level for xt_LOG and ebt_log since printk format was
  converted from <.> to a 2 bytes pattern using ASCII SOH, from Joe Perches.

* Two security fixes for the TCP connection tracking targeting off-path attacks,
  from Jozsef Kadlecsik. The problem was discovered by Jan Wrobel and it is
  documented in: http://mixedbit.org/reflection_scan/reflection_scan.pdf.

You can pull these changes from:

git://1984.lsi.us.es/nf master

Thanks!

Eric Dumazet (1):
  netfilter: take care of timewait sockets

Joe Perches (1):
  netfilter: log: Fix log-level processing

Jozsef Kadlecsik (2):
  netfilter: Mark SYN/ACK packets as invalid from original direction
  netfilter: Validate the sequence number of dataless ACK packets as well

 net/bridge/netfilter/ebt_log.c         |    2 +-
 net/netfilter/nf_conntrack_proto_tcp.c |   29 +++++++++----------------
 net/netfilter/nfnetlink_log.c          |   14 ++++++------
 net/netfilter/xt_LOG.c                 |   37 ++++++++++++++++----------------
 4 files changed, 38 insertions(+), 44 deletions(-)

-- 
1.7.10.4

