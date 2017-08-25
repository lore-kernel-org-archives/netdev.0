From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH net-next v2 0/5] net: updates for IPv6 Segment Routing
Date: Fri, 25 Aug 2017 09:56:43 +0200
Message-ID: <20170825075648.5061-1-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:35822 "EHLO
        smtp1.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754521AbdHYH4X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 03:56:23 -0400
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp1.sgsi.ucl.ac.be (Postfix) with ESMTPS id 65D3F67DDB7
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 09:56:13 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v2: seg6_lwt_headroom() is not relevant for lwtunnel_input_redirect()
    use cases, and L2ENCAP only uses this redirection. Fix incoherence
    between arbitrary MAC header size support and fixed headroom
    computation by setting only LWTUNNEL_STATE_INPUT_REDIRECT for L2ENCAP
    mode.

This patch series provides several updates for the SRv6 implementation. The
first patch leverages the existing infrastructure to support encapsulation
of IPv4 packets. The second patch implements the T.Encaps.L2 SR function,
enabling to encapsulate an L2 Ethernet frame within an IPv6+SRH packet.
The last three patches update the seg6local lightweight tunnel, and mainly
implement four new actions: End.T, End.DX2, End.DX4 and End.DT6.

David Lebrun (5):
  ipv6: sr: add support for ip4ip6 encapsulation
  ipv6: sr: add support for encapsulation of L2 frames
  ipv6: sr: enforce IPv6 packets for seg6local lwt
  ipv6: sr: add helper functions for seg6local
  ipv6: sr: implement additional seg6local actions

 include/net/seg6.h                 |   3 +-
 include/uapi/linux/seg6_iptunnel.h |  18 ++-
 net/ipv6/Kconfig                   |   1 +
 net/ipv6/seg6_iptunnel.c           |  72 +++++++--
 net/ipv6/seg6_local.c              | 314 ++++++++++++++++++++++++++++---------
 5 files changed, 317 insertions(+), 91 deletions(-)

-- 
2.10.2
