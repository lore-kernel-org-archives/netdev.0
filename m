From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 14586] New: bridge on bonding interface: DHCP
 replies don't get through
Date: Thu, 12 Nov 2009 14:55:29 -0800
Message-ID: <20091112145529.303c2659@nehalam>
References: <bug-14586-10286@http.bugzilla.kernel.org/>
	<20091112143913.3d89e4f4.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	bridge@lists.linux-foundation.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: harald.dunkel@t-online.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:55694 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754674AbZKLW4K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 17:56:10 -0500
In-Reply-To: <20091112143913.3d89e4f4.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> I would like to run a bridge for kvm on a bonding interface (4 * 1Gbit, Intel
> e1000e). Problem: The DHCPDISCOVER packets sent by the guest show up on my dhcp
> server as expected, but the DHCPOFFER sent as a reply doesn't reach the guest
> behind the bridge.
> 
> Using tcpdump on host and guest I can see the DHCPOFFER on the bond0 and br0
> interface, but it never shows up on vnet0 or on the guest's eth0.
> 
> If I drop the bonding interface and use the host's eth2 for the bridge instead,
> then there is no such problem.
> 
> Kernel on host and guest is 2.6.31.5. Attached you can find more information
> about my setup. 
> 

What is the configuration?
# brctl showstp virbr0
# brctl showmacs virbr0

Is dhclient being run on the bridge interface?
# cat /proc/net/ptype

# cat /proc/net/bonding/bond0


How is bond and bridge configured? Are bonding bridges (wrong)
or bridging bonded interfaces?

Are all links up?

Since this is the initial packet it will have to be flood forwarded by
the bridge, is there any iptables/netfilter rule that might be blocking
packets?
