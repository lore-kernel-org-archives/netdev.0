From: Maxime Bizon <mbizon@freebox.fr>
Subject: VLAN rx acceleration bypasses bridge
Date: Thu, 15 Oct 2009 01:58:05 +0200
Message-ID: <1255564685.21615.131.camel@sakura.staff.proxad.net>
Reply-To: mbizon@freebox.fr
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>, shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g21.free.fr ([212.27.42.6]:44362 "EHLO smtp6-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754632AbZJNX6u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2009 19:58:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Patrick, Stephen & all,


If I do:

# vconfig add eth0 100
# brctl addbr br0
# brctl addif br0 eth0

Then eth0.100 gets no more packet and br0.100 should be used instead to
get tagged packets.

But, if vlan rx acceleration is enabled on eth0, then vlan 100 packets
no longer go through bridge, and eth0.100 is to be used instead.

This is fixable, but I'm not sure which behavior is preferred ?


In case we prefer the first one, how could someone bridge untagged
packets from eth0 with some tagged packets from eth1, and some tagged
packets from eth0 with untagged packets from eth1 ?

Something like this, which currently works when vlan rx accel is on:

# vconfig add eth0 100
# vconfig add eth1 100
# brctl addbr br0
# brctl addif br0 eth0
# brctl addif br0 eth1.100
# brctl addbr br1
# brctl addif br1 eth0.100
# brctl addif br1 eth1


Regards,

-- 
Maxime


