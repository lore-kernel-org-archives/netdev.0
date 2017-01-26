From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC ipsec-next] IPsec GRO
Date: Thu, 26 Jan 2017 07:50:54 +0100
Message-ID: <1485413456-31197-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        "Sowmini Varadhan" <sowmini.varadhan@oracle.com>,
        Ilan Tayari <ilant@mellanox.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:35520 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751787AbdAZGvU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Jan 2017 01:51:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This introduces a device independent napi instance that
handles GRO for IPsec. I was not able to use gro cells
directly because I don't have a netdevice where I can
hang off the napi instance. We now may have a secpath
at a GRO merged skb, so we need to drop it. This is the
only cange to the generic networking code.

The packet still travels two times through the stack,
but might be aggregated in the second round. We can
avoid the second round with implementing GRO callbacks
for the IPsec protocols. This will be a separate patchset
as this needs some more generic networking changes because
of the asynchronous nature of IPsec.
