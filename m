From: "Hen, Shmulik" <shmulik.hen@intel.com>
Subject: RE: Bonding driver makes bad use of ethtool
Date: Fri, 12 Sep 2003 17:55:21 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E791C176A6139242A988ABA8B3D9B38A014C9539@hasmsx403.iil.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "Matthew Wilcox" <willy@debian.org>, <bonding-devel@lists.sourceforge.net>,
   "Noam, Amir" <amir.noam@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Matthew Wilcox [mailto:willy@debian.org]
> Sent: Friday, September 12, 2003 5:28 PM
> To: bonding-devel@lists.sourceforge.net; Noam, Amir
> Cc: netdev@oss.sgi.com
> Subject: Bonding driver makes bad use of ethtool
> 
> 
> 
> ethtool is being abused by the bonding driver.  ifenslave is passing
> in which ABI version it wants to use via the ETHTOOL_GDRVINFO call.
> This cannot continue in the ethtool_ops scheme, and it's my opinion this
> shouldn't've been done in the first place.
> 
> I suggest a new ioctl to set your ABI version and delete this bad use
> of ETHTOOL_GDRVINFO.
> 
> -- 
> "It's not Hollywood.  War is real, war is primarily not about defeat or
> victory, it is about death.  I've seen thousands and thousands of dead bodies.
> Do you think I want to have an academic debate on this subject?" -- Robert Fisk
> 
>
---------1---------2---------3---------4---------5---------6---------7---------8

For the next feature enhancement for bonding, which will enable
hot operations, we're adding a new ioctl hook the same way other
intermediate network drivers like VLAN and bridging drivers have.
It will be able to take care of exactly that.

In general, since bonding is an Ethernet like device, shouldn't
it also be able to support ethtool calls ? We've noticed that the
tool itself refuses to talk to bonding, probably since the device
name isn't 'ethX', but it could be made to support all non-hardware
specific ethtool options so management applications and network
startup scripts would benefit from the enhanced support (e.g. add
support for ethtool's get link status query so the ifup script would
be able to configure bonding when DHCP is enabled, etc.).

-- 
| Shmulik Hen   Advanced Network Services  |
| Israel Design Center, Jerusalem          |
| LAN Access Division, Platform Networking |
| Intel Communications Group, Intel corp.  |
