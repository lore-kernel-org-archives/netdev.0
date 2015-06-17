From: Florian Fainelli <f.fainelli@gmail.com>
Subject: DSA: Exposing CPU port [Was: Re: [PATCH 3/3] net: dsa: Allow
 configuration of CPU & DSA port speeds/duplex]
Date: Wed, 17 Jun 2015 11:40:10 -0700
Message-ID: <CAGVrzcaJ-jTp797U3TVX_xa4qdErb0LE2G4=btk5Yus=s=OipA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrew Lunn <andrew@lunn.ch>, David <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Cory Tusar <cory.tusar@pid1solutions.com>,
	netdev <netdev@vger.kernel.org>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:34154 "EHLO
	mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755953AbbFQSkv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 14:40:51 -0400
Received: by oigx81 with SMTP id x81so40951940oig.1
        for <netdev@vger.kernel.org>; Wed, 17 Jun 2015 11:40:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-06-17 11:09 GMT-07:00 Vivien Didelot <vivien.didelot@savoirfairelinux.com>:
> Hi Andrew, All,
>
> On 12/06/15 10:18, Andrew Lunn wrote:
>> By default, DSA and CPU ports are configured to the maximum speed the
>> switch supports. However there can be use cases where the peer device
>> port is slower. Allow a fixed-link property to be used with the DSA
>> and CPU port in the device tree, and use this information to configure
>> the port.
>
> Would it be a good idea for DSA to expose the "cpu" port to userspace as well?
> That way, it'd be possible to use ethtool to set the port speed and duplex
> mode, or dump registers (this would have saved me quite some time in dev).

My problem with that approach would be that we would expose a "cpu"
net_device in a way that it is not usable beyond statistics and
control knobs. In terms of data-path, you would not really want to
have it usable (sending data from the CPU to other ports, that's
already what other net_devices do), as it would be a duplicate
interface with respect to how the "master" net_device in DSA (aka
unmodified Ethernet driver) works. Having e.g: eth0 send DSA-tagged
packets today is already very confusing to users (they do not
necessarily understand why this interface does or how it works), so
having a "cpu" interface would cause more trouble here.

>
> Also, in my RFC for 802.1Q support [1], I assume the CPU port to be a tagged
> member of each VLAN. But someone may want to add a VLAN with swp3 and swp4
> only, and another VLAN with swp0, swp1 and the CPU port. Am I correct? This is
> currently not possible, but with an exposed "cpu" interface, the user could
> explicitly add the CPU port to a VLAN.

If we do put, say swp0 and swp1 in VLAN1, and CPU port is not in this
VLAN1, we cannot learn any traffic from it, this might be an
acceptable use-case, but I am not sure if there is much we get from
not adding the CPU to this VLAN membership, am I missing something?
-- 
Florian
