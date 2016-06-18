From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH v3 net-next v3 00/14] net: dsa: mv88e6xxx: probe compatible
Date: Fri, 17 Jun 2016 20:07:22 -0400
Message-ID: <20160618000736.5598-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Ben Dooks <ben.dooks@codethink.co.uk>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:39159 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753625AbcFRAIN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 20:08:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset factorizes the legacy DSA probing and the new MDIO probing
functions with a few helpers.

This will allow us to use a compatible chip info to describe how to access the
SMI device and its switch ID register at probe time.

For the legacy probe, we fix the compatible info to 88E6085. For the MDIO
probe, we will use the compatible info from the device node data.

The first 5 patches are already reviewed.
The next 3 patches are cosmetics, with no functional changes.
The next 4 patches add probe helpers and pass the compatible info.
The last 2 patches extend the info structure to store the SMI access mode and
the location of the switch ID register.

Changes since v2 [2]:

  - do not guess compatible model in legacy probe
  - add low level SMI API using a chip structure
  - allocate before probe and detection
  - add 3 cosmetic patches

Changes since v1 [1]:

  - merge style fix from Ben Dooks
  - add Acked-by/Reviewed-by tags
  - drop one compatible string per model
  - detect the SMI device based on the compatible info
  - add an SMI ops structure

[1] https://lkml.org/lkml/2016/6/8/1201
[2] https://lkml.org/lkml/2016/6/14/671

Vivien Didelot (14):
  net: dsa: mv88e6xxx: fix style issues
  net: dsa: mv88e6xxx: remove redundant assignments
  net: dsa: mv88e6xxx: use already declared variables
  net: dsa: mv88e6xxx: do not increment bus refcount
  net: dsa: mv88e6xxx: add switch register helpers
  net: dsa: mv88e6xxx: use gpio get optional variant
  net: dsa: mv88e6xxx: remove table args in info lookup
  net: dsa: mv88e6xxx: rename smi_mutex to reg_lock
  net: dsa: mv88e6xxx: add chip allocation helper
  net: dsa: mv88e6xxx: add SMI init helper
  net: dsa: mv88e6xxx: add detection helper
  net: dsa: mv88e6xxx: pass compatible info
  net: dsa: mv88e6xxx: add addressing mode to info
  net: dsa: mv88e6xxx: add port base address to info

 drivers/net/dsa/mv88e6xxx.c | 508 ++++++++++++++++++++++++++++----------------
 drivers/net/dsa/mv88e6xxx.h |  27 ++-
 2 files changed, 343 insertions(+), 192 deletions(-)

-- 
2.8.3
