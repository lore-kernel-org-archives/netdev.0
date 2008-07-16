From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 0/2]: VLAN filtering fixes
Date: Wed, 16 Jul 2008 11:43:32 +0200
Message-ID: <487DC2C4.9030006@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50183 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755279AbYGPJnf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 05:43:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These two patches contain the last bits of my VLAN + tcpdump fixes.
Currently some (all?) drivers have inconsistent behaviour wrt. VLAN
filtering and promiscous mode:

They start with disabled VLAN filtering, meaning all VLAN packets
are received on packet sockets. When adding the first VLAN, VLAN
filtering is enabled and only packets for locally configured VLANs
are received, even in promiscous mode. In most cases VLAN filtering
is disabled again when removing the last VLAN, igxbe keeps it enabled
permanently however.

These patches change the Intel drivers to always enable VLAN filtering
while not in promiscous mode since there is little point in receiving
VLAN packets while nothing is interested in them, but disable filtering
while in promiscous mode so all VLANs are visible to packet sockets.

There are four more drivers that support VLAN filtering that I didn't
adapt to this behaviour since I'm not sure about what exactly they
currently do. All four of tehuti, starfire, ehea and via-velocity
have a flag for the hardware to enable promiscous mode, its unknown
to me whether this also automatically disables VLAN filtering.
Any information on this someone might have is appreciated.

