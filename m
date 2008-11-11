From: David Madore <david.madore@ens.fr>
Subject: atl1e Ethernet driver not seeing packets sent to 33:33:00:00:00:01 multicast
Date: Tue, 11 Nov 2008 14:31:08 +0100
Message-ID: <20081111133108.GA7124@clipper.ens.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Linux Kernel Mailing-List <linux-kernel@vger.kernel.org>,
	Linux NetDev Mailing-List <netdev@vger.kernel.org>,
	atl1-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nef2.ens.fr ([129.199.96.40]:3028 "EHLO nef2.ens.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753334AbYKKNbM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2008 08:31:12 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This is on Ubuntu 8.10 "Intrepid Ibex" using its stock kernel
(2.6.27-7.16), with an Eee PC 901 whose Ethernet adapter is (according
to lspci):

04:00.0 Ethernet controller: Attansic Technology Corp. L1 Gigabit Ethernet Adapter (rev b0)

using driver atl1e of said kernel.

_Unless_ the network device is put in promiscuous mode (e.g., by
running tcpdump), it does not see packets sent to Ethernet multicast
address 33:33:00:00:00:01.  E.g., IPv6 packets to ff02::1
(ip6-allnodes) are not seen.

Practical consequence: IPv6 is broken, because router advertisements
are not received.

("ip maddr show" does give "link  33:33:00:00:00:01" among the
subscribed multicast addresses, so it's not a config problem.)

Is this a known problem?  Is there a patch fixing it?

Until then, a workaround is to put the device in promiscuous mode.

Happy hacking,

-- 
     David A. Madore
    (david.madore@ens.fr,
     http://www.madore.org/~david/ )
