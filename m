From: Chris J Arges <chris.j.arges@canonical.com>
Subject: net: bonding inside a bridge does not work when using arp monitoring
Date: Tue, 17 Jan 2012 16:11:51 -0600
Message-ID: <4F15F227.8000909@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jiri Bohac <jbohac@suse.cz>, leonardo.borda@canonical.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:47838 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755234Ab2AQWLy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2012 17:11:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Currently arp_monitoring does not work when the below configuration is
used. The idea is to have vlans for every virtual bridge, this way we
can have many networks in a KVM (virtualization setup) while still
having arp_monitoring through br0.
PS: FYI this setup does work with miimon activated.

eth0----+ +----bond0.100----br0-100---{+virtual machines
          | |
          +----bond0----+----br0---(using fixed ip)->--{LAN where the
arp_ip_target resides}
          | |
eth1----+ +----bond0.200----br0-200---{+virtual machines

br0 --> br0 in my understanding is an untagged vlan therefore it
provides access to my LAN. So I am able to access that server from my
internal network.
br0-100 and br0-200 -> Vlans over a bridged interface will allow me to
have many virtual machines in the same vlan on each bridged interface.

More information about this bug can be found in the bug reports [2] and [3].

First thing would be to understand if this setup is correct.
In addition, any further tests can be done by myself or Leonardo Borda.

Looking at the kernel messages it looks like br0 is not able to send out
ARP notifications.
The question is:

1. Can we do that since we also have br0-{1,2}00 hooked up to bond.100
and bond.200 ?
2. Also looking at the /etc/network/interfaces configuration example the
vlans do not have an IP address which may play a role as per the
bonding.txt documentation [1].

A potentially relevant thread that I found was here [4]. Could this
patch affect this particular set up?

Thanks,
--chris j arges

[1] - http://www.kernel.org/doc/Documentation/networking/bonding.txt
[2] - https://bugs.launchpad.net/ubuntu/+source/linux/+bug/736226
[3] - https://bugzilla.kernel.org/show_bug.cgi?id=31822
[4] - http://kerneltrap.org/mailarchive/linux-netdev/2010/4/28/6275890
