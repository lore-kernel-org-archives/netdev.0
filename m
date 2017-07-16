From: Yotam Gigi <yotamg@mellanox.com>
Subject: Re: IGMP snooping, switchdev and local multicast receiver on br
 interface
Date: Sun, 16 Jul 2017 11:17:54 +0300
Message-ID: <8a4c1da0-e009-fddd-c5a3-b5e2858c577f@mellanox.com>
References: <20170714144949.GG21743@lunn.ch>
 <878tjr2fyp.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>, Elad Raz <eladr@mellanox.com>,
        Ido Schimmel <idosch@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr20046.outbound.protection.outlook.com ([40.107.2.46]:13760
        "EHLO EUR02-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751010AbdGPISB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 16 Jul 2017 04:18:01 -0400
In-Reply-To: <878tjr2fyp.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/14/2017 06:30 PM, Vivien Didelot wrote:
> Hi All,
>
> Andrew Lunn <andrew@lunn.ch> writes:
>
>> I've been testing IGMP snooping support with DSA, putting MDB entries
>> into the switch so that traffic only goes out ports where there has
>> been an interest indicated via IGMP. It mostly works, but i've come
>> across one use case which does not.
>>
>> I have a multicast listener running on the host, performing a
>> setsockopt(IP_ADD_MEMBERSHIP) on the bridge interface. It is not an
>> unreasonable thing to want to do, e.g. a WiFi access point listening
>> to mDNS, or running other multicast protocols, a STB wanting to
>> receive a multicast video stream to display on the set, etc.
>>
>> I'm not seeing any switchdev operations when the IP_ADD_MEMBERSHIP is
>> called. So there is no indication that the switch should add an MDB
>> entry to forward traffic to the host.
>>
>> Im i missing something, or is this not implemented?

You are not missing, we did not add that support yet. Currently the hardware MDB
does not get updated with mcast_routers. The flood tables does get updated
though.

> I follow Andrew's question with another multicast issue I'm having:
>
> It seems like there is no way to add a multicast group via its MAC
> address. All iproute2 and kernel bridge code assumes IP multicast
> (0x0800 IPv4 and 0x86DD IPv6.)
>
> But there are valid cases where you might want to add an L2 multicast
> group on a specific VLAN ID, e.g. for 0x88F7 PTP, 0x88BA Multicast
> sampled values, one of the 802.1D reserved 01-80-C2-* addresses, or any
> proprietary protocol addresses.
>
> There is the ip-maddress VLAN-unaware tool using RTM_NEWADDR which isn't
> bound to switchdev, or bridge-mdb which only accepts a IPv4 or IPv6 grp.
>
> I tried to hack a PoC in iproute2 (http://ix.io/yuJ) but the kernel
> counterpart is not trivial at all. *br_mdb_entry only play with br_ip...
>
> Any thoughts on this?

We did not have this usecase yet, but what you say make perfect sense :)

It is weird for me too that one can not configure MDB with MAC address.

>
> Regards,
>
>         Vivien
