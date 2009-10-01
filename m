From: "Ira W. Snyder" <iws@ovro.caltech.edu>
Subject: Performance questions using bridge and macvlan
Date: Thu, 1 Oct 2009 14:21:33 -0700
Message-ID: <20091001212133.GD28963@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ovro.ovro.caltech.edu ([192.100.16.2]:39711 "EHLO
	ovro.ovro.caltech.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752672AbZJAVVa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 17:21:30 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all,

I've got an "interesting" network setup (using bridge), and I wonder if
macvlan might help me get some more performance. Unfortunately, there
isn't much documentation for macvlan, so I'm asking here.

I have a computer acting as an ethernet bridge. NIC A is on a network
with a 1500 byte mtu. NIC B is a point-to-point ethernet device with a
64K mtu.

Adding both devices to a bridge using brctl works as expected. The
computer attached to NIC B can send/recv normal ethernet traffic onto
the outside network through NIC A.

Unfortunately, the bridge code does not fragment packets, and so the 64K
mtu is reduced to a 1500 byte mtu. This kills performance by a factor of
about 5x on the point-to-point device. All of my tests were using
netperf/netserver running on the machine doing the bridging.

Without bridge, using full 64K mtu packets, netperf gives ~600mbit/sec.
With brigde, using 1500 byte mtu packets, netperf gives ~120mbit/sec.

My question is this: is it possible to setup routing or macvlans such
that any traffic from the bridge machine itself travels across the
point-to-point link (at full 64K mtu), but any other traffic goes
through the bridge (using 1500 byte mtu).

I'm aware that either running NAT or routing will fragment packets and
solve my problem, but this introduces some complexity in my network
setup that I would like to avoid.

Thanks,
Ira
