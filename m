From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC ipsec-next] IPsec offload, part one
Date: Wed, 4 Jan 2017 09:23:45 +0100
Message-ID: <1483518230-6777-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        Ilan Tayari <ilant@mellanox.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:52392 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758340AbdADIuI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 4 Jan 2017 03:50:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the first part of the IPsec offload work we
talked at the IPsec workshop at the last netdev
conference. I plan to apply this to ipsec-next
after this round of review.

Patch 1 and 2 try to avoid skb linearization in
the ESP layer.

Patch 3 introduces a hepler to seup the esp trailer.

Patch 4 prepares the generic network code for
IPsec GRO. The main reason why we need this, is
that we need to reinject the decrypted inner
packet back to the GRO layer.

Patch 5 introduces GRO handlers for ESP, GRO
can enabled with a IPsec offload config option.
This config option will also be used for the
upcomming hardware offload.

David, patch 3 touches generic networking code.
Is it ok to integrate such a generic preparation
patch into an IPsec pull request, or do you
prefer to get it as a separate patch?
