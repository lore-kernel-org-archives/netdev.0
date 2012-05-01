From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: 3.4-rc: NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed
 out
Date: Tue, 1 May 2012 20:04:23 +0200
Message-ID: <20120501200423.6804dcf0@stein>
References: <20120501182405.3dda59b9@stein>
	<20120501172748.GA17117@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:52883 "EHLO
	einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758537Ab2EASE1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2012 14:04:27 -0400
In-Reply-To: <20120501172748.GA17117@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On May 01 Francois Romieu wrote:
> Stefan Richter <stefanr@s5r6.in-berlin.de> :
> [...]
> > I switched from 3.3 to 3.4-rc5 yesterday and am getting the following warning
> > some time after boot (e.g. this time about two hours after boot).  What's up
> > with that?
> 
> The device stopped being able to transmit anything at some point (netdev
> watchdog message). The warnings always look the same. If the device does
> not recover, we have a problem. Do we ?

So far it always recovers.

> [...]
> > There are no noticeable issues, but I don't run anything demanding on the
> > interface right now which would make any downtime obvious.
> 
> I don't understand: is it a low traffic interface or a no traffic one ?

It is connected to a 100 Mbit/s switch + router and from there to a cable
modem (average traffic about 40 kBit/s, peak maybe 5 Mbit/s or so) and to
another PC for very occasional NFS and ssh (peak = what 100baseT is able
to).

The latter kind of usage did not coincide with one of those events yet, I
think.  At least I haven't noticed.  And the former kind of usage is
unreliable enough externally that I only noticed those transmit queue
time-outs from their showing up in the syslog.

> > It is an RTL8168(?) on an Asus M3A78-EM motherboard.
> 
> dmesg | grep XID should identify the chipset. You may consider sending
> an 'ethtool eth0' and 'ethtool -i eth0'.

# dmesg | grep XID
r8169 0000:0b:00.0: eth0: RTL8168c/8111c at 0xffffc9000005e000,
00:23:54:91:8a:2b, XID 1c4000c0 IRQ 49

# ethtool eth0
Settings for eth0:
        Supported ports: [ TP MII ]
        Supported link modes:   10baseT/Half 10baseT/Full 
                                100baseT/Half 100baseT/Full 
                                1000baseT/Half 1000baseT/Full 
        Supported pause frame use: No
        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Half 10baseT/Full 
                                100baseT/Half 100baseT/Full 
                                1000baseT/Half 1000baseT/Full 
        Advertised pause frame use: Symmetric Receive-only
        Advertised auto-negotiation: Yes
        Link partner advertised link modes:  10baseT/Half 10baseT/Full 
                                             100baseT/Half 100baseT/Full 
        Link partner advertised pause frame use: Symmetric
        Link partner advertised auto-negotiation: Yes
        Speed: 100Mb/s
        Duplex: Full
        Port: MII
        PHYAD: 0
        Transceiver: internal
        Auto-negotiation: on
        Supports Wake-on: pumbg
        Wake-on: g
        Current message level: 0x00000033 (51)
                               drv probe ifdown ifup
        Link detected: yes

# ethtool -i eth0
driver: r8169
version: 2.3LK-NAPI
firmware-version: 
bus-info: 0000:0b:00.0
supports-statistics: yes
supports-test: no
supports-eeprom-access: no
supports-register-dump: yes
-- 
Stefan Richter
-=====-===-- -=-= ----=
http://arcgraph.de/sr/
