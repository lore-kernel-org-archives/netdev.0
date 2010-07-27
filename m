From: David Lamparter <equinox@diac24.net>
Subject: BUG: net-next netns teardown bridge bug "waiting for lo to become
 free."
Date: Tue, 27 Jul 2010 17:25:14 +0200
Message-ID: <20100727152514.GA13413@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:38993 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751887Ab0G0PuF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jul 2010 11:50:05 -0400
Received: from jupiter.n2.diac24.net ([2001:8d8:81:5c2:21b:fcff:fe4c:9e6f])
	by spaceboyz.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.71)
	(envelope-from <equinox@diac24.net>)
	id 1Odm1t-0005xF-OX
	for netdev@vger.kernel.org; Tue, 27 Jul 2010 17:25:17 +0200
Received: from equinox by jupiter.n2.diac24.net with local (Exim 4.72)
	(envelope-from <equinox@diac24.net>)
	id 1Odm1q-0003uN-ML
	for netdev@vger.kernel.org; Tue, 27 Jul 2010 17:25:17 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(no idea who to Cc on this...)

Hi,


i've recently been playing with network namespaces under net-next
feb8f478... and have been able to reproducibly cause:

netconsole: network logging stopped, interface lo unregistered
netconsole: network logging stopped, interface lo unregistered
unregister_netdevice: waiting for lo to become free. Usage count = 4
netconsole: network logging stopped, interface lo unregistered
(repeat.)

i can trigger this with

unshare -n -- /bin/bash -c 'ip link add link lo veth0 type veth peer
name veth3 netns 1; brctl addbr br0; ip l s br0 up; ip a l; sleep 8'

(It happens when the netns is going down.)

Without the "ip l s br0 up" it does not happen; the veth I have added
for "notification" when the namespace goes down, it is probably not
related.

I'm looking into this, but i'm not versed in Linux kernel code, so my
luck in fixing this might be limited. Some reference taken in bridge
"up"? Should the bridge be set "down" on netns teardown?


-David

