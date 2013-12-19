From: Florian Fainelli <f.fainelli@gmail.com>
Subject: ixgbevf: suspicious skb->pkt_type check
Date: Thu, 19 Dec 2013 10:08:54 -0800
Message-ID: <CAGVrzcbYgy--jh_C6op39+DZqqkS5=Dmuu57uUGSnEr0TZ6DUw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev <netdev@vger.kernel.org>, e1000-devel@lists.sourceforge.net,
	jeffrey.t.kirsher@intel.com,
	John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f182.google.com ([209.85.216.182]:53577 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754238Ab3LSSJg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 13:09:36 -0500
Received: by mail-qc0-f182.google.com with SMTP id e16so1269026qcx.13
        for <netdev@vger.kernel.org>; Thu, 19 Dec 2013 10:09:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi John,

In commit 815cccbf ("ixgbe: add setlink, getlink support to ixgbe and
ixgbevf") this line was added:


+               if ((skb->pkt_type & (PACKET_BROADCAST | PACKET_MULTICAST)) &&
+                   !(compare_ether_addr(adapter->netdev->dev_addr,
+                                       eth_hdr(skb)->h_source))) {

This looks suspicious to me since skb->pkt_type is not a bitmask, but
holds only one value at a time,  and with this check you would also
match any value which has the lower two bits set, so PACKET_OTHERHOST,
PACKET_LOOPBACK and PACKET_FASTROUTE are also matching the first part
of the check.
-- 
Florian
