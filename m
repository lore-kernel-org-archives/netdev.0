From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC ipsec-next 0/5] IPsec GRO layer decapsulation
Date: Tue, 7 Feb 2017 10:14:06 +0100
Message-ID: <1486458851-4920-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        "Sowmini Varadhan" <sowmini.varadhan@oracle.com>,
        Ilan Tayari <ilant@mellanox.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:44748 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753165AbdBGJOX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 7 Feb 2017 04:14:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds a software GRO codepath for IPsec ESP.
The ESP gro_receive callback functions decapsulate the
ESP packets at the GRO layer and reinject them back with
gro_cells_receive(). This saves a complete round through
the stack for IPsec ESP packets.

We also need this for ESP HW offload, because HW decrypt but
does not decapsulate the packet. We need to decapsulate before
the inbound policy check, otherwise this check will fail.

Patches 2 an 3 prepare the generic code for packet consuming
gro callbacks.
