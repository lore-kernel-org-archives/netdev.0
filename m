From: Stephen Hemminger <stephen@networkplumber.org>
Subject: openvswitch MTU patch needed in 4.10 stable
Date: Tue, 9 May 2017 08:46:56 -0700
Message-ID: <20170509084656.53f2d590@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:34643 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754544AbdEIPq7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 11:46:59 -0400
Received: by mail-pg0-f50.google.com with SMTP id u28so1692736pgn.1
        for <netdev@vger.kernel.org>; Tue, 09 May 2017 08:46:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Could you queue the patch to stable?

Begin forwarded message:

Date: Tue, 09 May 2017 08:21:46 +0000
From: bugzilla-daemon@bugzilla.kernel.org
To: stephen@networkplumber.org
Subject: [Bug 195695] New: openvswitch: Set internal device max mtu to ETH_MAX_MTU


https://bugzilla.kernel.org/show_bug.cgi?id=195695

            Bug ID: 195695
           Summary: openvswitch: Set internal device max mtu to
                    ETH_MAX_MTU
           Product: Networking
           Version: 2.5
    Kernel Version: 4.10
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: stephen@networkplumber.org
          Reporter: endre@basis-consulting.com
        Regression: No

Can not use jumbo frames with openvswitch bridge in kernel 4.10. This is fixed
in kernel 4.11:

Commit 91572088e3fd ("net: use core MTU range checking in core net
infra") changed the openvswitch internal device to use the core net
infra for controlling the MTU range, but failed to actually set the
max_mtu as described in the commit message, which now defaults to
ETH_DATA_LEN.

This patch fixes this by setting max_mtu to ETH_MAX_MTU after
ether_setup() call.

Fixes: 91572088e3fd ("net: use core MTU range checking in core net infra")
Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
Signed-off-by: David S. Miller <davem@davemloft.net>

Diffstat (limited to 'net/openvswitch/vport-internal_dev.c')
-rw-r--r--
net/openvswitch/vport-internal_dev.c
2



1 files changed, 2 insertions, 0 deletions
diff --git a/net/openvswitch/vport-internal_dev.c
b/net/openvswitch/vport-internal_dev.c
index 09141a1..89193a6 100644
--- a/net/openvswitch/vport-internal_dev.c
+++ b/net/openvswitch/vport-internal_dev.c
@@ -149,6 +149,8 @@ static void do_setup(struct net_device *netdev)
 {
        ether_setup(netdev);

+       netdev->max_mtu = ETH_MAX_MTU;
+
        netdev->netdev_ops = &internal_dev_netdev_ops;

        netdev->priv_flags &= ~IFF_TX_SKB_SHARING;

Br.
Endre Vaade

-- 
You are receiving this mail because:
You are the assignee for the bug.
