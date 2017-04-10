From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH v2 00/12] ftgmac100: Rework batch 3 - TX path
Date: Mon, 10 Apr 2017 11:15:14 +1000
Message-ID: <20170410011526.4509-1-benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:56664 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750705AbdDJBPb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 9 Apr 2017 21:15:31 -0400
Received: from pasglop.ozlabs.ibm.com (localhost.localdomain [127.0.0.1])
        by gate.crashing.org (8.14.1/8.13.8) with ESMTP id v3A1FRSE024698
        for <netdev@vger.kernel.org>; Sun, 9 Apr 2017 20:15:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is version 2 of the third batch of updates to
the ftgmac100 driver.

This one tackles the TX path of the driver. This provides the
bulk of the performance improvements by adding support for
fragmented sends along with a bunch of cleanups.

Version 2 fixes a patch splitting mistake and uses
eth_skb_pad() (which uses skb_put_padto) to pad ethernet
frames rather than skb_padto(), thus removing the need to
also pad the packet headlen in a couple of places. 

Subsequent batches will add various features (ethtool functions,
vlan offlan, ...) and cleanups.
