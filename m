From: Davide Caratti <dcaratti@redhat.com>
Subject: [RFC PATCH net-next 5/5] Documentation: add description of skb_sctp_csum_help
Date: Mon, 23 Jan 2017 17:52:46 +0100
Message-ID: <52ee0cbecd0541d52e837d8c2836b44b3dd647d4.1485177252.git.dcaratti@redhat.com>
References: <cover.1485177252.git.dcaratti@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7398 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751418AbdAWQ7X (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 11:59:23 -0500
In-Reply-To: <cover.1485177252.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add description of skb_sctp_csum_help in networking/checksum-offload.txt;
while at it, remove reference to skb_csum_off_chk* functions, since they
are not present anymore in Linux since commit cf53b1da73bd ('Revert "net:
Add driver helper functions to determine checksum"').

Reviewed-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Signed-off-by: Davide Caratti <dcaratti@redhat.com>
---
 Documentation/networking/checksum-offloads.txt | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/Documentation/networking/checksum-offloads.txt b/Documentation/networking/checksum-offloads.txt
index 56e3686..cb7a7e5 100644
--- a/Documentation/networking/checksum-offloads.txt
+++ b/Documentation/networking/checksum-offloads.txt
@@ -49,9 +49,9 @@ A driver declares its offload capabilities in netdev->hw_features; see
  and csum_offset given in the SKB; if it tries to deduce these itself in
  hardware (as some NICs do) the driver should check that the values in the
  SKB match those which the hardware will deduce, and if not, fall back to
- checksumming in software instead (with skb_checksum_help or one of the
- skb_csum_off_chk* functions as mentioned in include/linux/skbuff.h).  This
- is a pain, but that's what you get when hardware tries to be clever.
+ checksumming in software instead (with skb_checksum_help or
+ skb_sctp_csum_help functions as mentioned in include/linux/skbuff.h).
+ This is a pain, but that's what you get when hardware tries to be clever.
 
 The stack should, for the most part, assume that checksum offload is
  supported by the underlying device.  The only place that should check is
@@ -60,7 +60,8 @@ The stack should, for the most part, assume that checksum offload is
  may include other offloads besides TX Checksum Offload) and, if they are
  not supported or enabled on the device (determined by netdev->features),
  performs the corresponding offload in software.  In the case of TX
- Checksum Offload, that means calling skb_checksum_help(skb).
+ Checksum Offload, that means calling skb_sctp_csum_help(skb) for SCTP
+ packets, and skb_checksum_help(skb) for other packets.
 
 
 LCO: Local Checksum Offload
-- 
2.7.4
