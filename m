From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: RE: em1 is visible to iproute2 but not ethtool or tcpdump
Date: Fri, 15 Mar 2013 01:05:26 +0000
Message-ID: <804857E1F29AAC47BF68C404FC60A1844D040615@ORSMSX102.amr.corp.intel.com>
References: <CALCETrV0SP+z_acyRTV++uZCFafJ7h+Ef9_NQ1tKrqOAiiVt8w@mail.gmail.com>
 <804857E1F29AAC47BF68C404FC60A1844D040373@ORSMSX102.amr.corp.intel.com>
 <CALCETrXrOxSOiczSLNSd3=bTHZX+G5NUQ+mvBDC71SX4PTkSPA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Network Development <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:21363 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751626Ab3COBF3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Mar 2013 21:05:29 -0400
In-Reply-To: <CALCETrXrOxSOiczSLNSd3=bTHZX+G5NUQ+mvBDC71SX4PTkSPA@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Andy Lutomirski [mailto:luto@amacapital.net]
> Sent: Thursday, March 14, 2013 3:43 PM
> To: Allan, Bruce W
> Cc: Network Development; e1000-devel@lists.sourceforge.net
> Subject: Re: em1 is visible to iproute2 but not ethtool or tcpdump
> 
> On Thu, Mar 14, 2013 at 1:45 PM, Allan, Bruce W <bruce.w.allan@intel.com>
> wrote:
> >> -----Original Message-----
> >> From: netdev-owner@vger.kernel.org [mailto:netdev-
> >> owner@vger.kernel.org] On Behalf Of Andy Lutomirski
> >> Sent: Thursday, March 14, 2013 9:54 AM
> >> To: Network Development
> >> Cc: e1000-devel@lists.sourceforge.net
> >> Subject: em1 is visible to iproute2 but not ethtool or tcpdump
> >>
> >> My e1000e device is em1.  It has this rather strange behavior on
> >> Fedora's 3.8.1 (although 3.7.something did the same thing, I believe):
> >>
> >> $ ip link show dev em1
> >> 6: em1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc
> >> pfifo_fast
> >> state DOWN qlen 1000
> >>     link/ether f0:de:f1:59:f6:c9 brd ff:ff:ff:ff:ff:ff
> >> $ strace -e socket,ioctl ethtool em1
> >> socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) = 3
> >> Settings for em1:
> >> ioctl(3, SIOCETHTOOL, 0x7fffa6c554d0)   = -1 ENODEV (No such device)
> >> Cannot get device settings: No such device
> >> ioctl(3, SIOCETHTOOL, 0x7fffa6c554d0)   = -1 ENODEV (No such device)
> >> Cannot get wake-on-lan settings: No such device
> >> ioctl(3, SIOCETHTOOL, 0x7fffa6c554d0)   = -1 ENODEV (No such device)
> >> Cannot get message level: No such device
> >> ioctl(3, SIOCETHTOOL, 0x7fffa6c554d0)   = -1 ENODEV (No such device)
> >> Cannot get link status: No such device
> >> No data available
> >> +++ exited with 75 +++
> >> $ sudo tcpdump -i em1
> >> tcpdump: em1: SIOETHTOOL(ETHTOOL_GTSO) ioctl failed: No such device
> >>
> >> A sufficient number of rmmod/modprobe cycles will make it work.
> >>
> >> This is, perhaps, helpful:
> >>
> >> $ sudo ip link set dev em1 name foobar
> >> RTNETLINK answers: Device or resource busy
> >> $ sudo ip link set dev em1 down
> >> $ sudo ip link set dev em1 name foobar
> >> $ sudo ethtool foobar
> >> Settings for foobar:
> >>       Supported ports: [ TP ]
> >>       Supported link modes:   10baseT/Half 10baseT/Full
> >>                               100baseT/Half 100baseT/Full
> >>                               1000baseT/Full
> >>       Supported pause frame use: No
> >>       Supports auto-negotiation: Yes
> >>       Advertised link modes:  10baseT/Half 10baseT/Full
> >>                               100baseT/Half 100baseT/Full
> >>                               1000baseT/Full
> >>       Advertised pause frame use: No
> >>       Advertised auto-negotiation: Yes
> >>       Speed: Unknown!
> >>       Duplex: Unknown! (255)
> >>       Port: Twisted Pair
> >>       PHYAD: 1
> >>       Transceiver: internal
> >>       Auto-negotiation: on
> >>       MDI-X: Unknown
> >>       Supports Wake-on: pumbg
> >>       Wake-on: g
> >>       Current message level: 0x00000007 (7)
> >>                              drv probe link
> >>       Link detected: no
> >> $ sudo ip link set dev foobar name em1
> >> $ sudo ethtool em1
> >> Settings for em1:
> >>       Supported ports: [ TP ]
> >>       Supported link modes:   10baseT/Half 10baseT/Full
> >>                               100baseT/Half 100baseT/Full
> >>                               1000baseT/Full
> >>       Supported pause frame use: No
> >>       Supports auto-negotiation: Yes
> >>       Advertised link modes:  10baseT/Half 10baseT/Full
> >>                               100baseT/Half 100baseT/Full
> >>                               1000baseT/Full
> >>       Advertised pause frame use: No
> >>       Advertised auto-negotiation: Yes
> >>       Speed: Unknown!
> >>       Duplex: Unknown! (255)
> >>       Port: Twisted Pair
> >>       PHYAD: 1
> >>       Transceiver: internal
> >>       Auto-negotiation: on
> >>       MDI-X: Unknown
> >>       Supports Wake-on: pumbg
> >>       Wake-on: g
> >>       Current message level: 0x00000007 (7)
> >>                              drv probe link
> >>       Link detected: no
> >> $
> >>
> >> This bug (?) isn't a show-stopper, but it's rather annoying.  I
> >> suspect a core networking bug, not an e1000e bug, but I cc'd the e1000
> >> people just in case.
> >
> > This sounds related to some runtime power management (RPM) issues
> that have
> > already been fixed.  First check whether RPM is enabled for your device -
> the file
> > /sys/devices/pciNNNN:NN/NNNN:NN:NN.N/power/control (where
> NNNN... is
> > the PCI domain, bus, slot and function of your device) will contain "auto"
> when it
> > is enabled.  To disable RPM for that device, change the value in the file to
> "on".
> 
> Seems to work.  Oddly, I'm pretty sure I've seen this bug even when
> something's plugged in.
> 
> Is the fix heading to stable?
> 
> --Andy

I believe the patches have been submitted to stable.
