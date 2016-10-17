From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH v3 RFC 0/2] ixgbe: ixgbe_atr() bug fixes
Date: Mon, 17 Oct 2016 14:12:37 -0700
Message-ID: <cover.1476737917.git.sowmini.varadhan@oracle.com>
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:20099 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964894AbcJQVMt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 17:12:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two bug fixes:
- ixgbe_atr() should check for protocol == udp in the
  skb->encapsulation case (instead of !=)
- ixgbe_atr() should make sure the non-paged data has the
  needed network/transport header for computing l4_proto.

v3: Alex Duyck comments

Sowmini Varadhan (2):
  ixgbe: ixgbe_atr() should access udp_hdr(skb) only for UDP packets
  ixgbe: ixgbe_atr() compute l4_proto only if non-paged data has
    network/transport headers

 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   19 ++++++++++++++++++-
 1 files changed, 18 insertions(+), 1 deletions(-)
