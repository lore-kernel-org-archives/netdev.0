From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 0/7] net: dsa: tagger simplification
Date: Tue, 30 May 2017 10:21:24 -0400
Message-ID: <20170530142131.23568-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:43306 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751004AbdE3OXp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 10:23:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The DSA layer has a dsa_device_ops structure containing two members to
tag and untag the proprietary switch header, called xmit and rcv.

The switch tree and slave private structures respectively hold a useless
copy of the rcv and xmit functions. The tagging implementations use
useless goto labels and only the rcv caller (partially) handles the SKB
freeing. The rcv function also contains unused arguments.

This patchset removes the copy of rcv and xmit functions, the unused
arguments of the rcv signature and the useless labels, and handles
freeing of the SKB in the xmit caller.

Vivien Didelot (7):
  net: dsa: hide dsa_uses_tagged_protocol code
  net: dsa: remove useless rcv copy in DSA tree
  net: dsa: remove unused arguments of tagger rcv
  net: dsa: free orig skb on rcv if reallocated
  net: dsa: remove useless goto label in tagger rcv
  net: dsa: remove useless copy of tagger xmit
  net: dsa: factor skb freeing on xmit

 include/net/dsa.h     |  9 +--------
 net/dsa/dsa.c         | 12 +++++++++---
 net/dsa/dsa2.c        |  2 --
 net/dsa/dsa_priv.h    |  7 +------
 net/dsa/legacy.c      |  2 --
 net/dsa/slave.c       |  6 +++---
 net/dsa/tag_brcm.c    | 21 ++++++---------------
 net/dsa/tag_dsa.c     | 25 ++++++++-----------------
 net/dsa/tag_edsa.c    | 25 ++++++++-----------------
 net/dsa/tag_lan9303.c |  8 ++------
 net/dsa/tag_mtk.c     | 19 +++++--------------
 net/dsa/tag_qca.c     | 21 ++++++---------------
 net/dsa/tag_trailer.c | 18 +++++-------------
 13 files changed, 54 insertions(+), 121 deletions(-)

-- 
2.13.0
