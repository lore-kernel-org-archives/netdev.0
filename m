From: Jacek Konieczny <jajcus@bnet.pl>
Subject: Re: "new style" netdevice allocation patch for TUN driver (2.4.18 kernel)
Date: Thu, 1 Aug 2002 19:52:06 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020801175204.GC17308@nic.nigdzie>
References: <20020801133506.GA22073@serwus.bnet.pl> <200208011743.VAA07150@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Content-Disposition: inline
In-Reply-To: <200208011743.VAA07150@sex.inr.ac.ru>
List-Id: netdev.vger.kernel.org

On Thu, Aug 01, 2002 at 09:43:23PM +0400, kuznet@ms2.inr.ac.ru wrote:
> Hello!
> 
> > network. And "unregister_netdevice: waiting for tun0 to become free"
> 
> This smells like a leakage. I think this should be investigated.
I am not sure. Sometimes it is not easy to free such device.

> > devices, and that only the "old style" devices have this problem.
> > I had similar problem with VLAN devices some time ago, so I checked VLAN
> > driver sources too.
> 
> Well, switching to "new style" does not solve the problem. If we have
> a leakage, it will continue silently which is even worse.
> Probably, you should to define NET_REFCNT_DEBUG in net/core/dev.c
> to track what happens with the device.
After applying my patch, the device unregistration is usually defered,
but finally it is finished. On system shutdown, when all routes are
removed, all interfaces downed and all processes killed the device will
not be used any more and the device is freed. Without the patch my
system doesn't even come to this point, as it stops on the first process
which tries to access any network device (eg. any iproute2 command).
Usually it stops on postfix shutdown. Probably because I use the tun
device for tunneling SMTP connections to my home machine. Probably
shutting down postfix before openvpn would help, but failing to do this
should not hang the system.

And even if there is a bug in tun module it should never prevent system
from clean shutdown. Even if the device will be never freed and module
unloaded. So I thing this patch (or similar) should be applied.

Greets,
        Jacek
