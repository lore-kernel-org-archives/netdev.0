From: Daniel Mack <zonque@gmail.com>
Subject: [PATCH 0/3] Handle stuck TX queue bug in AT8030 PHY
Date: Wed,  4 Jun 2014 11:00:36 +0200
Message-ID: <1401872439-30107-1-git-send-email-zonque@gmail.com>
Cc: davem@davemloft.net, marek.belisko@gmail.com, ujhelyi.m@gmail.com,
	Daniel Mack <zonque@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:49965 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751094AbaFDJAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2014 05:00:54 -0400
Received: by mail-wi0-f178.google.com with SMTP id cc10so982592wib.17
        for <netdev@vger.kernel.org>; Wed, 04 Jun 2014 02:00:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These three small patches circument a hardware bug in AT8030 PHYs that
leads to stuck TX FIFO queues when the link goes away while there are
pending patches in der outbound queue. This bug has been confirmed by
the vendor, and their only proposed fix is to apply a hardware reset
every time the link goes down.

I tried to fix this with a software reset routine a few months back,
but it turns out that a software reset does in fact not help here.

This new series hence makes use of the newly added way to augment
auto-probed PHY devices with DT information. This way, a 'reset-gpios'
node can be specified, and if present, the gpio will be used to reset
the PHY. In contrast to the first series I sent, this one now saves
the register contents before the reset cycle and restores them
afterwards.

I'm well aware that such a hardware reset is not a nice thing to do,
but we have to cope with hardware that leaves us no other choice.


Thanks,
Daniel


Daniel Mack (3):
  net: phylib: add adjust_state callback to phy device
  net: phy: at803x: use #defines for supported PHY ids
  net: phy: at803x: Add support for hardware reset

 drivers/net/phy/at803x.c | 119 ++++++++++++++++++++++++++++++++++++++++++++---
 drivers/net/phy/phy.c    |   3 ++
 include/linux/phy.h      |   3 ++
 3 files changed, 119 insertions(+), 6 deletions(-)

-- 
1.9.3
