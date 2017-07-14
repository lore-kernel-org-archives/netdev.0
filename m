From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: IGMP snooping, switchdev and local multicast receiver on br interface
Date: Fri, 14 Jul 2017 11:30:54 -0400
Message-ID: <878tjr2fyp.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170714144949.GG21743@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>, Elad Raz <eladr@mellanox.com>,
        Ido Schimmel <idosch@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:33792 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753912AbdGNPdf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2017 11:33:35 -0400
In-Reply-To: <20170714144949.GG21743@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

Andrew Lunn <andrew@lunn.ch> writes:

> I've been testing IGMP snooping support with DSA, putting MDB entries
> into the switch so that traffic only goes out ports where there has
> been an interest indicated via IGMP. It mostly works, but i've come
> across one use case which does not.
>
> I have a multicast listener running on the host, performing a
> setsockopt(IP_ADD_MEMBERSHIP) on the bridge interface. It is not an
> unreasonable thing to want to do, e.g. a WiFi access point listening
> to mDNS, or running other multicast protocols, a STB wanting to
> receive a multicast video stream to display on the set, etc.
>
> I'm not seeing any switchdev operations when the IP_ADD_MEMBERSHIP is
> called. So there is no indication that the switch should add an MDB
> entry to forward traffic to the host.
>
> Im i missing something, or is this not implemented?

I follow Andrew's question with another multicast issue I'm having:

It seems like there is no way to add a multicast group via its MAC
address. All iproute2 and kernel bridge code assumes IP multicast
(0x0800 IPv4 and 0x86DD IPv6.)

But there are valid cases where you might want to add an L2 multicast
group on a specific VLAN ID, e.g. for 0x88F7 PTP, 0x88BA Multicast
sampled values, one of the 802.1D reserved 01-80-C2-* addresses, or any
proprietary protocol addresses.

There is the ip-maddress VLAN-unaware tool using RTM_NEWADDR which isn't
bound to switchdev, or bridge-mdb which only accepts a IPv4 or IPv6 grp.

I tried to hack a PoC in iproute2 (http://ix.io/yuJ) but the kernel
counterpart is not trivial at all. *br_mdb_entry only play with br_ip...

Any thoughts on this?


Regards,

        Vivien
