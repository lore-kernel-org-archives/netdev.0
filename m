From: "Thomas 'Dent' Mirlacher" <dent@cosy.sbg.ac.at>
Subject: dev->type oddities
Date: Fri, 21 Jun 2002 18:55:44 +0200 (MET DST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.GSO.4.05.10206211840080.16167-100000@mausmaki.cosy.sbg.ac.at>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com
List-Id: netdev.vger.kernel.org

hi list,

can someone please send a comment the stuff below?

net_device->type:
	o holds the interface hardware type (according to netdevice.h)
	o is set to ARPHRD_* (which should be ARP hardware identifiers)
	o in the arp code there are a couple of places where the type
		gets mapped to the correct ARP hardware header type

hmm, so the type doesn't specify the arp hardware type, it specifies
the mac/datalink type.

wouldn't it be cleaner to split dev->type into

	dev->datalink_type (or dev->mac_type)
and
	dev->arp_type
?

plus defining DLT_* or whatever defines for the mac/datalink type.

this would cost an int per device, but would improve readability? and
helps getting rid of the type to arp type mappings in the arp code.
(plus userspace apps could also benefit - using datalink_type as we do
 right now, will keep libpcap and friends happy, and dhcp apps could
 use the arp type (so they can support new datalink types, which use
 an already known arp_type) without the need to add a switch for the
 new datalink type - 802.11 for example)

any comments?

thanks,

	tm

-- 
in some way i do, and in some way i don't.
