From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Memory leak in 2.6.11-rc1?
Date: Thu, 27 Jan 2005 12:33:26 -0800
Message-ID: <20050127123326.2eafab35.davem@davemloft.net>
References: <20050123091154.GC16648@suse.de>
	<20050123011918.295db8e8.akpm@osdl.org>
	<20050123095608.GD16648@suse.de>
	<20050123023248.263daca9.akpm@osdl.org>
	<20050123200315.A25351@flint.arm.linux.org.uk>
	<20050124114853.A16971@flint.arm.linux.org.uk>
	<20050125193207.B30094@flint.arm.linux.org.uk>
	<20050127082809.A20510@flint.arm.linux.org.uk>
	<20050127004732.5d8e3f62.akpm@osdl.org>
	<16888.58622.376497.380197@robur.slu.se>
	<20050127164918.C3036@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, akpm@osdl.org, torvalds@osdl.org,
        alexn@dsv.su.se, kas@fi.muni.cz, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Russell King <rmk+lkml@arm.linux.org.uk>
In-Reply-To: <20050127164918.C3036@flint.arm.linux.org.uk>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 27 Jan 2005 16:49:18 +0000
Russell King <rmk+lkml@arm.linux.org.uk> wrote:

> notice how /proc/net/stat/rt_cache says there's 1336 entries in the
> route cache.  _Where_ are they?  They're not there according to
> /proc/net/rt_cache.

When the route cache is flushed, that kills a reference to each
entry in the routing cache.  If for some reason, other references
remain (route connected to socket, some leak in the stack somewhere)
the route cache entry can't be immediately completely freed up.

So they won't be listed in /proc/net/rt_cache (since they've been
removed from the lookup table) but they will be accounted for in
/proc/net/stat/rt_cache until the final release is done on the
routing cache object and it can be completely freed up.

Do you happen to be using IPV6 in any way by chance?
