From: Daniel Mack <zonque@gmail.com>
Subject: [PATCH v2 0/3] Handle stuck TX queue bug in AT8030 PHY
Date: Wed, 18 Jun 2014 11:01:40 +0200
Message-ID: <1403082103-23709-1-git-send-email-zonque@gmail.com>
Cc: davem@davemloft.net, marek.belisko@gmail.com, ujhelyi.m@gmail.com,
	Daniel Mack <zonque@gmail.com>
To: netdev@vger.kernel.org, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:45317 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964781AbaFRJBy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 05:01:54 -0400
Received: by mail-wg0-f50.google.com with SMTP id x13so485520wgg.33
        for <netdev@vger.kernel.org>; Wed, 18 Jun 2014 02:01:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These three small patches circument a hardware bug in AT8030 PHYs that
leads to stuck TX FIFO queues when the link goes away while there are
pending patches in der outbound queue. This bug has been confirmed by
the vendor, and their only proposed fix is to apply a hardware reset
every time the link goes down.


Thanks,
Daniel

v1 -> v2:
	* Rename phy device callback from adjust_state to link_change_notify


Daniel Mack (3):
  net: phylib: add link_change_notify callback to phy device
  net: phy: at803x: use #defines for supported PHY ids
  net: phy: at803x: Add support for hardware reset

 drivers/net/phy/at803x.c | 195 ++++++++++++++++++++++++++++++++++++-----------
 drivers/net/phy/phy.c    |   3 +
 include/linux/phy.h      |   9 +++
 3 files changed, 163 insertions(+), 44 deletions(-)

-- 
1.9.3
