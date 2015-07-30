From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/4] net: GENET, SYSTEMPORT and DSA netconsole
Date: Thu, 30 Jul 2015 12:35:35 -0700
Message-ID: <1438284939-2750-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch, cphealy@gmail.com, mathieu@codeaurora.org,
	jonasj76@gmail.com, andrey.volkov@nexvision.fr,
	Chris.Packham@alliedtelesis.co.nz, alexander.h.duyck@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34790 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751323AbbG3TjM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 15:39:12 -0400
Received: by pacan13 with SMTP id an13so28577390pac.1
        for <netdev@vger.kernel.org>; Thu, 30 Jul 2015 12:39:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series adds support for netconsole in the GENET, SYSTEMPORT and DSA
drivers.

A small refactoring to the DSA transmit path is required to avoid duplicating
the dsa_netpoll_send_skb() into each and every tagging protocol supported.

Testing on e.g: mv643xx_eth and/or e1000e would be much appreciated!

David, this might conflict with my series adding NETIF_F_HW_SWITCH_TAG_{RX,TX},
if so, I will just rebase this one on top of net-next.

Thanks!

Florian Fainelli (4):
  net: bcmgenet: Add netconsole support
  net: systemport: Add netconsole support
  net: dsa: Refactor transmit path
  net: dsa: Add netconsole support

 drivers/net/ethernet/broadcom/bcmsysport.c     | 13 ++++
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 13 ++++
 net/dsa/dsa_priv.h                             |  8 ++-
 net/dsa/slave.c                                | 83 +++++++++++++++++++++++++-
 net/dsa/tag_brcm.c                             | 15 +----
 net/dsa/tag_dsa.c                              | 12 +---
 net/dsa/tag_edsa.c                             | 12 +---
 net/dsa/tag_trailer.c                          | 12 +---
 8 files changed, 126 insertions(+), 42 deletions(-)

-- 
2.1.0
