From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net): ipsec 2016-03-10
Date: Thu, 10 Mar 2016 11:24:24 +0100
Message-ID: <1457605469-17332-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:36672 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935312AbcCJKyR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Mar 2016 05:54:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) Add pmtu handling to vti, we need it do report
   pmtu informations for local generated packets.

2) The flowcache can hit an OOM condition if too
   many entries are in the gc_list. Fix this by
   counting the entries in the gc_list and refuse
   new allocations if the value is too high.

3) The inner headers are invalid after a xfrm transformation,
   so reset the skb encapsulation field ensure nobody tries
   access the inner headers. Otherwise tunnel divices stacked
   on top of xfrm may build the outer headers based on wrong
   informations.

4) Fix recource leeks for vti4/vti6 introduced with the
   pmtu handling.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit aac8d3c282e024c344c5b86dc1eab7af88bb9716:

  qmi_wwan: add "4G LTE usb-modem U901" (2016-02-16 20:39:32 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec.git master

for you to fetch changes up to 52717aa430949249993f1f7d570f70be863c2652:

  vti: Fix recource leeks on pmtu discovery (2016-03-03 07:45:09 +0100)

----------------------------------------------------------------
Steffen Klassert (5):
      vti: Add pmtu handling to vti_xmit.
      flowcache: Avoid OOM condition under preasure
      xfrm: Reset encapsulation field of the skb before transformation
      vti6: Fix dst_entry leek on pmtu discovery
      vti: Fix recource leeks on pmtu discovery

 include/net/netns/xfrm.h |  1 +
 net/core/flow.c          | 14 +++++++++++++-
 net/ipv4/ip_vti.c        | 14 ++++++++++++++
 net/ipv6/ip6_vti.c       |  3 ++-
 net/xfrm/xfrm_output.c   |  3 +++
 5 files changed, 33 insertions(+), 2 deletions(-)
