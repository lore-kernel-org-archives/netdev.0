From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC ipsec-next v2] IPsec GRO
Date: Fri, 27 Jan 2017 08:19:30 +0100
Message-ID: <1485501572-20908-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        Ilan Tayari <ilant@mellanox.com>
To: <netdev@vger.kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>,
        "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:39144 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753970AbdA0HTm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 27 Jan 2017 02:19:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This adds a dummy network device so that we can use gro_cells
for IPsec GRO. We now may have a secpath at a GRO merged skb,
so we need to drop it. This is the only change to the generic
networking code.

The packet still travels two times through the stack,
but might be aggregated in the second round. We can
avoid the second round with implementing GRO callbacks
for the IPsec protocols. This will be a separate patchset
as this needs some more generic networking changes because
of the asynchronous nature of IPsec.
