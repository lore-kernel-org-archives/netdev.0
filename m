From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net 0/2] bnx2x: Fix malicious VFs indication
Date: Fri, 9 Jun 2017 17:17:00 +0300
Message-ID: <20170609141702.20688-1-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <mschmidt@redhat.com>, Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0065.outbound.protection.outlook.com ([104.47.32.65]:52026
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751527AbdFIOR3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 9 Jun 2017 10:17:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It was discovered that for a VF there's a simple [yet uncommon] scenario
which would cause device firmware to declare that VF as malicious -
Add a vlan interface on top of a VF and disable txvlan offloading for
that VF [causing VF to transmit packets where vlan is on payload].

Patch #1 corrects driver transmission to prevent this issue.
Patch #2 is a by-product correcting PF behavior once a VF is declared
malicious.

Dave,

Please consider applying these to 'net'.

Thanks,
Yuval

Yuval Mintz (2):
  bnx2x: Allow vfs to disable txvlan offload
  bnx2x: Don't post statistics to malicious VFs

 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c   | 19 +++++++++++++++----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c | 13 ++++++++++++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h |  1 +
 3 files changed, 28 insertions(+), 5 deletions(-)

-- 
2.9.4
