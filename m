From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC 0/3] DSA and Marvell 88E6352 802.1q support
Date: Thu, 28 May 2015 17:37:12 -0400
Message-ID: <1432849035-8499-1-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <556723FF.7030606@roeck-us.net>
Cc: Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Jerome Oufella <jerome.oufella@savoirfairelinux.com>,
	Chris Healy <cphealy@gmail.com>, Jiri Pirko <jiri@resnulli.us>,
	Scott Feldman <sfeldma@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:63435 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754735AbbE1VhV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 17:37:21 -0400
In-Reply-To: <556723FF.7030606@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This RFC is based on v4.1-rc3.

It is meant to get a glance to the commits responsible to implement the
necessary NDOs between DSA and the Marvell 88E6352 switch driver.

With this support, I am able to create VLANs with (un)tagged ports, setting
their default VID, from a bridge.

To create a bridge containing all switch ports, with a VLAN ID 400, swp2 and
swp3 untagged (pvid), and swp4 tagged, the userspace commands look like this:

    ip link add name br0 type bridge
    [...]
    ip link set dev swp2 up master br0
    [...]
    bridge vlan add vid 400 pvid untagged dev swp2
    bridge vlan add vid 400 pvid untagged dev swp3
    bridge vlan add vid 400 dev swp4
    [...]
    ip link add link br0 name br0.400 type vlan id 400
    [...]
    bridge vlan add dev br0 vid 400 self

The code is currently being rebased to the latest net-next/master.

Seems like the way to go now is through switchdev attr getter/setter...

Vivien Didelot (3):
  net: dsa: add basic support for VLAN ndo
  net: dsa: mv88e6xxx: add support for VTU operations
  net: dsa: mv88e6352: add support for VLAN

 drivers/net/dsa/mv88e6352.c |   3 +
 drivers/net/dsa/mv88e6xxx.c | 309 ++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx.h |  28 ++++
 include/net/dsa.h           |   9 ++
 net/dsa/slave.c             |  76 ++++++++++-
 5 files changed, 423 insertions(+), 2 deletions(-)

-- 
2.4.1
