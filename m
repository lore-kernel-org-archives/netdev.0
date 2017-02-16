From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net-next): ipsec-next 2017-02-16
Date: Thu, 16 Feb 2017 13:18:34 +0100
Message-ID: <1487247527-17925-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:49288 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754441AbdBPMS4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Feb 2017 07:18:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) Make struct xfrm_input_afinfo const, nothing writes to it.
   From Florian Westphal.

2) Remove all places that write to the afinfo policy backend
   and make the struct const then.
   From Florian Westphal.

3) Prepare for packet consuming gro callbacks and add
   ESP GRO handlers. ESP packets can be decapsulated
   at the GRO layer then. It saves a round through
   the stack for each ESP packet.


Please note that this has a merge coflict between commit

63fca65d0863 ("net: add confirm_neigh method to dst_ops")

from net-next and

3d7d25a68ea5 ("xfrm: policy: remove garbage_collect callback")
a2817d8b279b ("xfrm: policy: remove family field")

from ipsec-next.

The conflict can be solved as it is done in linux-next.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit 152bff377653047c2a69c226435e2c3fd316b592:

  Merge branch 'bridge-improve-cache-utilization' (2017-02-06 22:53:14 -0500)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec-next.git master

for you to fetch changes up to 7785bba299a8dc8fe8390a0183dad3cafb3f1d80:

  esp: Add a software GRO codepath (2017-02-15 11:04:11 +0100)

----------------------------------------------------------------
Florian Westphal (7):
      xfrm: input: constify xfrm_input_afinfo
      xfrm: policy: xfrm_get_tos cannot fail
      xfrm: policy: xfrm_policy_unregister_afinfo can return void
      xfrm: policy: remove garbage_collect callback
      xfrm: policy: remove family field
      xfrm: policy: remove xfrm_policy_put_afinfo
      xfrm: policy: make policy backend const

Steffen Klassert (6):
      xfrm: Add a secpath_set helper.
      net: Add a skb_gro_flush_final helper.
      net: Prepare gro for packet consuming gro callbacks
      xfrm: Export xfrm_parse_spi.
      xfrm: Extend the sec_path for IPsec offloading
      esp: Add a software GRO codepath

 include/linux/netdevice.h       |  14 +++++
 include/net/xfrm.h              |  56 ++++++++++++++++---
 net/core/dev.c                  |   7 +++
 net/ethernet/eth.c              |   2 +-
 net/ipv4/Kconfig                |  13 +++++
 net/ipv4/Makefile               |   1 +
 net/ipv4/af_inet.c              |   2 +-
 net/ipv4/esp4_offload.c         | 106 ++++++++++++++++++++++++++++++++++++
 net/ipv4/xfrm4_input.c          |   6 +++
 net/ipv4/xfrm4_mode_transport.c |   4 +-
 net/ipv4/xfrm4_policy.c         |   9 ++--
 net/ipv4/xfrm4_protocol.c       |   3 +-
 net/ipv6/Kconfig                |  13 +++++
 net/ipv6/Makefile               |   1 +
 net/ipv6/esp6_offload.c         | 108 +++++++++++++++++++++++++++++++++++++
 net/ipv6/ip6_offload.c          |   2 +-
 net/ipv6/xfrm6_input.c          |  22 ++++----
 net/ipv6/xfrm6_mode_transport.c |   4 +-
 net/ipv6/xfrm6_policy.c         |   9 ++--
 net/ipv6/xfrm6_protocol.c       |   3 +-
 net/xfrm/Kconfig                |   4 ++
 net/xfrm/xfrm_input.c           |  99 +++++++++++++++++++++-------------
 net/xfrm/xfrm_policy.c          | 117 ++++++++++++++++------------------------
 23 files changed, 457 insertions(+), 148 deletions(-)
 create mode 100644 net/ipv4/esp4_offload.c
 create mode 100644 net/ipv6/esp6_offload.c
