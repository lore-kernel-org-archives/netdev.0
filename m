From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: BUG: net-next netns teardown bridge bug "waiting for lo to
 become free."
Date: Tue, 27 Jul 2010 10:02:49 -0700
Message-ID: <20100727100249.51ffc893@nehalam>
References: <20100727152514.GA13413@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56893 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751382Ab0G0RCw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jul 2010 13:02:52 -0400
In-Reply-To: <20100727152514.GA13413@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 27 Jul 2010 17:25:14 +0200
David Lamparter <equinox@diac24.net> wrote:

> (no idea who to Cc on this...)
> 
> Hi,
> 
> 
> i've recently been playing with network namespaces under net-next
> feb8f478... and have been able to reproducibly cause:
> 
> netconsole: network logging stopped, interface lo unregistered
> netconsole: network logging stopped, interface lo unregistered
> unregister_netdevice: waiting for lo to become free. Usage count = 4
> netconsole: network logging stopped, interface lo unregistered
> (repeat.)
> 
> i can trigger this with
> 
> unshare -n -- /bin/bash -c 'ip link add link lo veth0 type veth peer
> name veth3 netns 1; brctl addbr br0; ip l s br0 up; ip a l; sleep 8'
> 
> (It happens when the netns is going down.)
> 
> Without the "ip l s br0 up" it does not happen; the veth I have added
> for "notification" when the namespace goes down, it is probably not
> related.
> 
> I'm looking into this, but i'm not versed in Linux kernel code, so my
> luck in fixing this might be limited. Some reference taken in bridge
> "up"? Should the bridge be set "down" on netns teardown?

Loopback device is special and is referenced by routes etc.
You need to manually remove bridge, and all routes, neighbors and cache
before removing namespace.



-- 
