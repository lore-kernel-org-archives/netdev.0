From: Ryota Ozaki <ozaki.ryota@gmail.com>
Subject: [PATCH] doc: fix wrongly referencing dev->skb_mark
Date: Mon, 10 Oct 2016 20:15:39 +0900
Message-ID: <1476098139-6333-1-git-send-email-ozaki.ryota@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:35954 "EHLO
        mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751130AbcJJLdO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2016 07:33:14 -0400
Received: by mail-pa0-f66.google.com with SMTP id rw4so2228422pab.3
        for <netdev@vger.kernel.org>; Mon, 10 Oct 2016 04:33:13 -0700 (PDT)
Received: from fedora24.localdomain ([118.103.63.157])
        by smtp.gmail.com with ESMTPSA id bx5sm29847499pad.6.2016.10.10.04.15.50
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Oct 2016 04:15:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Section "Flooding L2 domain" says, to avoid duplicated flooding, if
skb->offload_fwd_mark is matched with dev->skb_mark, the kernel will
drop the packet. However, the relevant code in __dev_queue_xmit
compares skb->offload_fwd_mark with dev->offload_fwd_mark, not
dev->skb_mark. I guess the text is wrong.

Signed-off-by: Ryota Ozaki <ozaki.ryota@gmail.com>
---
 Documentation/networking/switchdev.txt | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/switchdev.txt b/Documentation/networking/switchdev.txt
index 31c3911..d4124a0 100644
--- a/Documentation/networking/switchdev.txt
+++ b/Documentation/networking/switchdev.txt
@@ -286,8 +286,8 @@ otherwise there will be duplicate packets on the wire.
 To avoid duplicate packets, the device/driver should mark a packet as already
 forwarded using skb->offload_fwd_mark.  The same mark is set on the device
 ports in the domain using dev->offload_fwd_mark.  If the skb->offload_fwd_mark
-is non-zero and matches the forwarding egress port's dev->skb_mark, the kernel
-will drop the skb right before transmit on the egress port, with the
+is non-zero and matches the forwarding egress port's dev->offload_fwd_mark,
+the kernel will drop the skb right before transmit on the egress port, with the
 understanding that the device already forwarded the packet on same egress port.
 The driver can use switchdev_port_fwd_mark_set() to set a globally unique mark
 for port's dev->offload_fwd_mark, based on the port's parent ID (switch ID) and
-- 
2.7.4
