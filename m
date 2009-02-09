From: Patrick McHardy <kaber@trash.net>
Subject: Re: accelerated vlan gives pcap tagged packets untagged
Date: Mon, 09 Feb 2009 14:23:01 +0100
Message-ID: <49902E35.6060506@trash.net>
References: <20090208123735.15d9ea4b@mjolnir.drzeus.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: Pierre Ossman <drzeus-list@drzeus.cx>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54558 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754813AbZBINXD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 08:23:03 -0500
In-Reply-To: <20090208123735.15d9ea4b@mjolnir.drzeus.cx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pierre Ossman wrote:
> I'm having some problems with r8169 and vlans. The basic problem is
> that pcap on eth1 gives me tagged packets, but in a form where it is
> impossible to tell it is tagged. This is causing problems for dhcpd:
> 
> Feb  6 20:04:22 asgard dhcpd: DHCPDISCOVER from 00:15:00:08:98:1f via eth1.2
> Feb  6 20:04:22 asgard dhcpd: DHCPDISCOVER from 00:15:00:08:98:1f via eth1
> Feb  6 20:04:23 asgard dhcpd: DHCPOFFER on 10.8.2.230 to 00:15:00:08:98:1f via eth1.2
> Feb  6 20:04:23 asgard dhcpd: DHCPOFFER on 10.8.0.128 to 00:15:00:08:98:1f via eth1
> Feb  6 20:04:23 asgard dhcpd: DHCPREQUEST for 10.8.2.230 (10.8.2.254) from 00:15:00:08:98:1f via eth1.2
> Feb  6 20:04:23 asgard dhcpd: DHCPACK on 10.8.2.230 to 00:15:00:08:98:1f via eth1.2
> Feb  6 20:04:23 asgard dhcpd: DHCPREQUEST for 10.8.2.230 (10.8.2.254) from 00:15:00:08:98:1f via eth1: wrong network.
> Feb  6 20:04:23 asgard dhcpd: DHCPNAK on 10.8.2.230 to 00:15:00:08:98:1f via eth1
> 
> I assume this is because the hardware supports vlans and handles all
> the tag stripping.
> 
> (I've confirmed with tcpdump that the packets lack tags when they are
> presented to userspace)
> 
> From what I can tell, I cannot fix this without rebuilding the kernel
> and removing the acceleration support from the r8169 driver. Is there
> some method I've overlooked?
> 
> Preferably, I'd like the kernel to expose to pcap what's on the wire
> (i.e. accelerated vs non-accelerated looks the same from userspace). If
> that means too much processing to be desirable, the next best thing
> would be to simply not show tagged packets on the raw interface. The
> ability to turn vlan acceleration on and off in the latter case would
> also be desirable for network debugging.

Current kernel version (I think starting with 2.6.28) relay the
VLAN tag information to userspace through packet sockets. The
current libpcap release from tcpdump.org (or the one Dave keeps
in a git tree on kernel.org) supports reconstructing the tags.

> Possibly related, all docs state that header reordering is disabled by
> default. But it is on by default here. This might be because of the
> acceleration, but the docs need some type of update either way. :)

I've been wondering about that myself :)
