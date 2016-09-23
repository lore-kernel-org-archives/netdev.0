From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC] IPsec performance optimizations
Date: Fri, 23 Sep 2016 09:53:37 +0200
Message-ID: <1474617228-26103-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        Ilan Tayari <ilant@mellanox.com>,
        "Boris Pismenny" <borisp@mellanox.com>,
        Ariel Levkovich <lariel@mellanox.com>,
        "Hay, Joshua A" <joshua.a.hay@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:45991 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758233AbcIWHyD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 03:54:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds several performance optimizations for the ESP IPsec
protocol. This RFC version is intended to be a discussion base for the
IPsec workshop at the netdev 1.2 conference.

The patchset has two parts, patches 1 - 4 are software optimizations.
These patches are complete and could go upstream after some review.

Patch 5 - 11 are needed to create an API for ESP offload to network
devices. Mellanox prepares the mlx5 driver for the use of the created
API, see 

https://git.kernel.org/cgit/linux/kernel/git/klassert/linux-stk.git/?h=net-next-ipsec-offload-api3

This part is still under development, changes are very likely before
it can go upstream.

Patch 1 and 2 try to avoid the linearization of ESP packets whenever
possible.

Patch 3 prepares the generic networking codepath for IPsec GRO.

Patch 4 implements software GRO a codepath for ESP on ipv4 and ipv6.

Patch 5 extends the skbuff gso_type to unsigned int. We need a GSO
flag for ESP, but all available gso_type flags are currently in use.

Patch 6 adds the needed netdev features to configure IPsec offloads.

Patch 7 adds gso handlers for esp4 and esp6, currently only used
in combination with ESP hardware offload.

Patch 8 - 9 prepares for IPsec hardware offloading.

Patch 10 implements an IPsec hardware offloading API.

Patch 11 allows for TSO and checksum offloading of the inner IPsec packet.
