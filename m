From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC ipsec-next 0/14] IPsec hardware offloding API
Date: Wed, 12 Apr 2017 08:26:39 +0200
Message-ID: <1491978413-5700-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        Ilan Tayari <ilant@mellanox.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:57556 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752278AbdDLG2M (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 02:28:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds the basic infrastructure for IPsec hardware
offloading, it creates a configuration API and adjusts the
packet path.

Patch 1 adds the needed netdev features to configure IPsec offloads.

Patch 2 - 4 prepares for IPsec hardware offloading.

Patch 5 implements the IPsec hardware offloading API.

Patch 5 - 8 reorganize esp_output so that we can use it
on layer 2 to implement the software fallback for the
case that a packet is rerouted to a device that does
not support IPsec offloading.

Patch 9 adds gso handlers for esp4 and esp6, this implements
the software fallback for GSO packets.

Patch 10 adds xfrm_replay_overflow functions for offloading.

Patch 11 changes ESP to use a synchronous crypto algorithm
on offloading, we don't have the option for asynchronous
returns when we handle IPsec at layer2.

Patch 12 adds a xfrm validate function to validate_xmit_skb.
This implements the software fallback for non GSO packets.

Patch 13 sets the inner_network and inner_transport members of
the SKB, as well as encapsulation, to reflect the actual positions
of these headers, and removes them only once encryption is done
on the payload.

Patch 14 prepares the ESP GRO codepath for hardware offloading.
