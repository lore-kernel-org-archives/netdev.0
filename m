From: Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
Subject: [PATCH v2 0/1] net: macb: initialize checksum when using checksum
Date: Mon, 29 Aug 2016 15:57:24 +0200
Message-ID: <1472479045-8814-1-git-send-email-helmut.buchsbaum@gmail.com>
References: <1471611898-3852-2-git-send-email-helmut.buchsbaum@gmail.com>
Cc: Michal Simek <michal.simek@xilinx.com>, netdev@vger.kernel.org,
        Cyrille Pitchen <cyrille.pitchen@atmel.com>,
        Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
To: David Miller <davem@davemloft.net>, tom@herbertland.com,
        Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33382 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756135AbcH2N6D (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 09:58:03 -0400
Received: by mail-wm0-f66.google.com with SMTP id o80so9715888wme.0
        for <netdev@vger.kernel.org>; Mon, 29 Aug 2016 06:58:03 -0700 (PDT)
In-Reply-To: <1471611898-3852-2-git-send-email-helmut.buchsbaum@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When working on upgrading the v3.x kernels of our embedded devices
to more recent 4.x kernels we noticed some of our proprietary networking
stuff is broken. Further investigations brought up an issue with small
UDP packets (data payload <= 2), which contained wrong UDP header
checksums.
We tracked this down to commit 85ff3d87bf2ef1fadcde8553628c60f79806fdb4
net/macb: add TX checksum offload feature.

It turns out that (at least) Zynq's GEM needs the checksum field set to 0
to correctly calculate the checksum.

Changes since v1:
 - dropped disabling HW checksum offload for Zynq
 - initialize checksum similar to net/ethernet/freescale/fec_main.c

Helmut Buchsbaum (1):
  net: macb: initialize checksum when using checksum offloading

 drivers/net/ethernet/cadence/macb.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

-- 
2.1.4
