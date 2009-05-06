From: Robert Olsson <robert@robur.slu.se>
Subject: SUN Neptune byte order bug in TCAM filter/ethtool
Date: Wed, 6 May 2009 18:16:07 +0200
Message-ID: <18945.47047.877878.307515@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David@robur.slu.se, "Miller <davem"@davemloft.net,
	Matheos.Worku@Sun.COM, Jens.Laas@its.uu.se, robert@robur.slu.se
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from robur.slu.se ([130.238.98.12]:57994 "EHLO robur.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755087AbZEFQ0D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 May 2009 12:26:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


David Miller writes:

 > >  FYI byte order seems reversed on Intel meaning you have to reverse
 > >  byte order for address and ports when adding TCAM entries via
 > >  ethtool.
 > 
 > Please report this formally with a reproduction script/commands/etc.
 > with netdev CC:'d as this is a very serious bug and exactly what I
 > tried to avoid have happen when I was so anal about the endian
 > oriented typing of the ethtool structures. :-//////////


First a disclaimer this our production system 2.6.29-rc2 but I haven't 
seen any patches since.


# This rule makes the TCAM drop pkts with IP-src 10.10.10.1 
# Note the reversed byte-order. Machine is Opteron little Endian.

ethtool -N  eth0  rx-class-rule-add ip4 udp sip 1.10.10.10 drop  

# The rule listed

ethtool  -n eth0  rx-class-rule-all 
Total 1 rules

      IPv4 Rule:   ID[84] Target[Discard]
      IP src addr[1.10.10.10] mask[255.255.255.255]
      IP dst addr[0.0.0.0] mask[0.0.0.0]
      L4 proto[UDP]
      L4 src port[0] mask[0x0]
      L4 dst port[0] mask[0x0]
      IP TOS[0x0] mask[0x0]

# The rule deleted

ethtool  -N eth0  rx-class-rule-del 84 


Cheers
					--ro

