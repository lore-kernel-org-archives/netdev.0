From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v3 0/5] net: dsa: tagger simplification
Date: Thu,  1 Jun 2017 16:07:10 -0400
Message-ID: <20170601200715.8438-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series clarifies the hot path, removes the labels in tagging
implementations, and frees the original SKB in the xmit caller.

Changes in v3:
  - drop removal of usused rcv arguments because they will be used later
  - include the new ksz tagging implementation
  - add reviewers' tags

Changes in v2:
  - do not remove tagger function copies
  - document hot path requirements
  - make netdev_uses_dsa simpler
  - add reviewers' tags

Vivien Didelot (5):
  net: dsa: comment hot path requirements
  net: dsa: do not cast dst
  net: dsa: remove dsa_uses_tagged_protocol
  net: dsa: remove out_drop label in taggers rcv
  net: dsa: factor skb freeing on xmit

 include/net/dsa.h     | 11 ++++-------
 net/dsa/dsa2.c        |  2 +-
 net/dsa/dsa_priv.h    |  1 +
 net/dsa/legacy.c      |  2 +-
 net/dsa/slave.c       |  8 ++++++--
 net/dsa/tag_brcm.c    | 17 +++++------------
 net/dsa/tag_dsa.c     | 21 +++++++--------------
 net/dsa/tag_edsa.c    | 21 +++++++--------------
 net/dsa/tag_ksz.c     |  4 +---
 net/dsa/tag_lan9303.c |  5 +----
 net/dsa/tag_mtk.c     | 15 ++++-----------
 net/dsa/tag_qca.c     | 17 +++++------------
 net/dsa/tag_trailer.c | 13 ++++---------
 13 files changed, 47 insertions(+), 90 deletions(-)

-- 
2.13.0
