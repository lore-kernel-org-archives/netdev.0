From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: [PATCH 0/2] igb: drop stats due to OS cannot keep up
Date: Thu, 07 May 2009 15:35:46 +0200
Message-ID: <1241703346.18487.22.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
To: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:54178 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753353AbZEGNfr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2009 09:35:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The following patchset address "drop" stats counters in the igb
driver (chips 82576 and 82575).  The drop stats addressed here
are due to the OS cannot keep up.

I have only tested it for the 82576 chip, as my (12 port) 82575
chip based NIC from Hotlava Systems recently died in my testlab :-(((

[First patch]
Implements reading of the per queue drop stats.
These stats only gets incremented if the DROP_EN bit it set (in
the SRRCTL register for that queue, or QDE reg is set).

[Second patch]
Address the case where the DROP_EN it NOT set.  In
this case a global register records the equivalent drop type. And
aggregation of these two types of drops into the device net_stats.

I strongly believe that these drops counters should be made
available to sysadm's through the normal device stats.  These
stats are essential when diagnosing server performance issues, as
these stats are due to the OS cannot keep up. I strongly believe
that it should be stored in the net_stats rx_fifo_errors counter,
to indicate performance issues.

-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer

