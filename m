From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net): ipsec 2016-05-04
Date: Wed, 4 May 2016 07:40:51 +0200
Message-ID: <1462340454-27922-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:56696 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751058AbcEDFlJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2016 01:41:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) The flowcache can hit an OOM condition if too
   many entries are in the gc_list. Fix this by
   counting the entries in the gc_list and refuse
   new allocations if the value is too high.

2) The inner headers are invalid after a xfrm transformation,
   so reset the skb encapsulation field to ensure nobody tries
   access the inner headers. Otherwise tunnel devices stacked
   on top of xfrm may build the outer headers based on wrong
   informations.

3) Add pmtu handling to vti, we need it to report
   pmtu informations for local generated packets.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit aac8d3c282e024c344c5b86dc1eab7af88bb9716:

  qmi_wwan: add "4G LTE usb-modem U901" (2016-02-16 20:39:32 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec.git master

for you to fetch changes up to d6af1a31cc72fbd558c7eddbc36f61bf09d1cf6a:

  vti: Add pmtu handling to vti_xmit. (2016-03-31 08:59:56 +0200)

----------------------------------------------------------------
Steffen Klassert (3):
      flowcache: Avoid OOM condition under preasure
      xfrm: Reset encapsulation field of the skb before transformation
      vti: Add pmtu handling to vti_xmit.

 include/net/netns/xfrm.h |  1 +
 net/core/flow.c          | 14 +++++++++++++-
 net/ipv4/ip_vti.c        | 18 ++++++++++++++++++
 net/xfrm/xfrm_output.c   |  3 +++
 4 files changed, 35 insertions(+), 1 deletion(-)
