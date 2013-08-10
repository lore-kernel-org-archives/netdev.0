From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/4] netfilter fixes for 3.11-rc4
Date: Sat, 10 Aug 2013 18:58:49 +0200
Message-ID: <1376153933-5747-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44405 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756677Ab3HJQ7V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Aug 2013 12:59:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains four netfilter fixes, they are:

* Fix possible invalid access and mangling of the TCPMSS option in
  xt_TCPMSS. This was spotted by Julian Anastasov.

* Fix possible off by one access and mangling of the TCP packet in
  xt_TCPOPTSTRIP, also spotted by Julian Anastasov.

* Fix possible information leak due to missing initialization of one
  padding field of several structures that are included in nfqueue and
  nflog netlink messages, from Dan Carpenter.

* Fix TCP window tracking with Fast Open, from Yuchung Cheng.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

Thanks!

----------------------------------------------------------------

The following changes since commit a661b43fd047ef501da43a19975415f861c7c3db:

  mlx5: fix error return code in mlx5_alloc_uuars() (2013-07-30 19:33:45 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to 356d7d88e088687b6578ca64601b0a2c9d145296:

  netfilter: nf_conntrack: fix tcp_in_window for Fast Open (2013-08-10 18:36:22 +0200)

----------------------------------------------------------------
Dan Carpenter (1):
      netfilter: nfnetlink_{log,queue}: fix information leaks in netlink message

Pablo Neira Ayuso (2):
      netfilter: xt_TCPMSS: fix handling of malformed TCP header and options
      netfilter: xt_TCPOPTSTRIP: fix possible off by one access

Yuchung Cheng (1):
      netfilter: nf_conntrack: fix tcp_in_window for Fast Open

 net/netfilter/nf_conntrack_proto_tcp.c |   12 ++++++++----
 net/netfilter/nfnetlink_log.c          |    6 +++++-
 net/netfilter/nfnetlink_queue_core.c   |    5 ++++-
 net/netfilter/xt_TCPMSS.c              |   28 ++++++++++++++++------------
 net/netfilter/xt_TCPOPTSTRIP.c         |   10 ++++++----
 5 files changed, 39 insertions(+), 22 deletions(-)
