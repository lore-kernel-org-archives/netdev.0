From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 0/4] net: GENET, SYSTEMPORT and DSA netconsole
Date: Fri, 31 Jul 2015 11:42:53 -0700
Message-ID: <1438368177-23942-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch, cphealy@gmail.com, mathieu@codeaurora.org,
	jonasj76@gmail.com, andrey.volkov@nexvision.fr,
	Chris.Packham@alliedtelesis.co.nz, alexander.h.duyck@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:35937 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751028AbbGaSpO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 14:45:14 -0400
Received: by pdjr16 with SMTP id r16so47943749pdj.3
        for <netdev@vger.kernel.org>; Fri, 31 Jul 2015 11:45:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series adds support for netconsole in the GENET, SYSTEMPORT and DSA
drivers.

A small refactoring to the DSA transmit path is required to avoid duplicating
the dsa_netpoll_send_skb() into each and every tagging protocol supported.

Testing on e.g: mv643xx_eth and/or e1000e would be much appreciated!

Changes in v2:

- properly disable/enable interrupts in GENET and SYSTEMPORT

- pass the reallocated SKB back to dsa_slave_xmit() in case a tag protocol had to
  alter the original SKB

Florian Fainelli (4):
  net: bcmgenet: Add netconsole support
  net: systemport: Add netconsole support
  net: dsa: Refactor transmit path to eliminate duplication
  net: dsa: Add netconsole support

 drivers/net/ethernet/broadcom/bcmsysport.c     | 18 +++++
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 20 ++++++
 net/dsa/dsa_priv.h                             |  8 ++-
 net/dsa/slave.c                                | 94 +++++++++++++++++++++++---
 net/dsa/tag_brcm.c                             | 15 +---
 net/dsa/tag_dsa.c                              | 12 +---
 net/dsa/tag_edsa.c                             | 12 +---
 net/dsa/tag_trailer.c                          | 12 +---
 8 files changed, 142 insertions(+), 49 deletions(-)

-- 
2.1.0
