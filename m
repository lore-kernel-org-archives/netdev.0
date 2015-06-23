From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH 0/3] net: dsa: mv88e6xxx: dump hardware VLANs
Date: Tue, 23 Jun 2015 17:46:07 -0400
Message-ID: <1435095970-18576-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:58489 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754891AbbFWVqP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 17:46:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset requires "net: dsa: add support for switchdev VLAN objects" [1].

Thanks to the switchdev bindings for ports' bridge_getlink, this patchset adds
support for dumping the hardware VLAN Table Unit of Marvell 88E6xxx compatible
switch chips.

It allows "bridge vlan" to query the hardware, and also brings a new debugfs
"vtu" file. A populated VLAN Table Unit can show the following output:

    # cat /sys/kernel/debug/dsa0/vtu
    VID  FID  SID  P0 P1 P2 P3 P4 P5 P6
    550  562  0    x  x  x  u  x  t  x
    1000 1012 0    x  x  t  x  x  t  x
    1200 1212 0    x  x  t  x  t  t  x

    # bridge vlan
    port	vlan ids
    swp0	None
    swp0
    swp1	None
    swp1
    swp2	1000
		1200

    swp2	1000
		1200

    swp3	550 PVID Egress Untagged

    swp3	550 PVID Egress Untagged

    swp4	1200

    swp4	1200

    br0		None

[1] https://lkml.org/lkml/2015/6/23/494

Vivien Didelot (3):
  net: dsa: mv88e6xxx: add debugfs interface for VTU
  net: dsa: mv88e6xxx: add support to dump VLANs
  net: dsa: mv88e6352: add support for port_vlan_dump

 drivers/net/dsa/mv88e6352.c |   1 +
 drivers/net/dsa/mv88e6xxx.c | 182 ++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx.h |  26 +++++++
 3 files changed, 209 insertions(+)

-- 
2.4.4
