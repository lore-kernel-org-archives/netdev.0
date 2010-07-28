From: David Lamparter <equinox@diac24.net>
Subject: Re: BUG: net-next netns teardown bridge bug "waiting for lo to
 become free."
Date: Wed, 28 Jul 2010 09:44:28 +0200
Message-ID: <20100728074428.GB13413@jupiter.n2.diac24.net>
References: <20100727152514.GA13413@jupiter.n2.diac24.net>
 <20100727100249.51ffc893@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:59472 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753093Ab0G1Hod (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jul 2010 03:44:33 -0400
Content-Disposition: inline
In-Reply-To: <20100727100249.51ffc893@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 27, 2010 at 10:02:49AM -0700, Stephen Hemminger wrote:
> David Lamparter <equinox@diac24.net> wrote:
> > unregister_netdevice: waiting for lo to become free. Usage count = 4
> > 
> > unshare -n -- /bin/bash -c 'ip link add link lo veth0 type veth peer
> > name veth3 netns 1; brctl addbr br0; ip l s br0 up; ip a l; sleep 8'
> > 
> > (It happens when the netns is going down.)
> > 
> > Without the "ip l s br0 up" it does not happen;
[...]
> > I'm looking into this, but i'm not versed in Linux kernel code, so my
> > luck in fixing this might be limited. Some reference taken in bridge
> > "up"? Should the bridge be set "down" on netns teardown?
> 
> Loopback device is special and is referenced by routes etc.
> You need to manually remove bridge, and all routes, neighbors and cache
> before removing namespace.

That doesn't do. I have namespaces which are only network namespaces and
they have only one or two processes like openvpn. openvpn can have bugs,
so it might just terminate. If it is the last process in the namespace,
the namespace needs to go, and correctly. Even if I had some "master
daemon" to tear down the namespace at the "end", who tells me that that
will work perfectly and not die? It shouldn't be possible to break the
network stack by just killing the wrong process...

I'll try reading the code today, maybe I can come up with the right
dereferences in the right places.


-David

