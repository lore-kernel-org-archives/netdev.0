From: Olaf Kirch <okir@suse.de>
Subject: Re: ip addr flush hangs
Date: Tue, 9 Mar 2004 20:47:56 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040309194756.GA11916@suse.de>
References: <20040309144824.GD14419@suse.de> <20040309150730.GE14419@suse.de> <20040309112529.4c013b9c.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040309112529.4c013b9c.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Mar 09, 2004 at 11:25:29AM -0800, David S. Miller wrote:
> > The attached patch disables reporting of multicast and anycast
> > addresses in inet6_dump_ifaddr
> 
> Better to fix /sbin/ip, Andi Kleen posted a patch for that tool
> in a thread on linux-kernel about this very issue.

His patch breaks ip addr flush completely, because it breaks the loop
before flushing the RTM_DELADDR packet to the netlink socket.

Even if you fix it to break out ofthe loop in the proper place, it is
still not entirely correct.  ip does addr list and addr flush in a loop,
because netlink can return only so many addresses in one packet. If you
break out of the loop unconditionally, as Andi does in his patch, you
break ip addr list/flush for systems with more than the normal number
of addresses per device.

I think IPv6 is really wrong in reporting multicast addresses via
RTM_GETADDR. IPv4 doesn't do this either.

Olaf
-- 
Olaf Kirch     |  Stop wasting entropy - start using predictable
okir@suse.de   |  tempfile names today!
---------------+ 
