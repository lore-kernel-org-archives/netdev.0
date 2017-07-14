From: Andrew Lunn <andrew@lunn.ch>
Subject: IGMP snooping, switchdev and local multicast receiver on br interface
Date: Fri, 14 Jul 2017 16:49:49 +0200
Message-ID: <20170714144949.GG21743@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Elad Raz <eladr@mellanox.com>, Ido Schimmel <idosch@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:54249 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753968AbdGNOtw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 14 Jul 2017 10:49:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Folks

I've been testing IGMP snooping support with DSA, putting MDB entries
into the switch so that traffic only goes out ports where there has
been an interest indicated via IGMP. It mostly works, but i've come
across one use case which does not.

I have a multicast listener running on the host, performing a
setsockopt(IP_ADD_MEMBERSHIP) on the bridge interface. It is not an
unreasonable thing to want to do, e.g. a WiFi access point listening
to mDNS, or running other multicast protocols, a STB wanting to
receive a multicast video stream to display on the set, etc.

I'm not seeing any switchdev operations when the IP_ADD_MEMBERSHIP is
called. So there is no indication that the switch should add an MDB
entry to forward traffic to the host.

Im i missing something, or is this not implemented?

Thanks
	Andrew
