From: Phil Oester <kernel@linuxace.com>
Subject: Re: Memory leak in 2.6.11-rc1?
Date: Thu, 27 Jan 2005 10:37:45 -0800
Message-ID: <20050127183745.GA13365@linuxace.com>
References: <20050123011918.295db8e8.akpm@osdl.org> <20050123095608.GD16648@suse.de> <20050123023248.263daca9.akpm@osdl.org> <20050123200315.A25351@flint.arm.linux.org.uk> <20050124114853.A16971@flint.arm.linux.org.uk> <20050125193207.B30094@flint.arm.linux.org.uk> <20050127082809.A20510@flint.arm.linux.org.uk> <20050127004732.5d8e3f62.akpm@osdl.org> <16888.58622.376497.380197@robur.slu.se> <20050127164918.C3036@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>, Andrew Morton <akpm@osdl.org>,
        torvalds@osdl.org, alexn@dsv.su.se, kas@fi.muni.cz,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20050127164918.C3036@flint.arm.linux.org.uk>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jan 27, 2005 at 04:49:18PM +0000, Russell King wrote:
> so obviously the GC does appear to be working - as can be seen from the
> number of entries in /proc/net/rt_cache.  However, the number of objects
> in the slab cache does grow day on day.  About 4 days ago, it was only
> about 600 active objects.  Now it's more than twice that, and it'll
> continue increasing until it hits 8192, where upon it's game over.

I can confirm the behavior you are seeing -- does seem to be a leak
somewhere.  Below from a heavily used gateway with 26 days uptime:

# wc -l /proc/net/rt_cache ; grep ip_dst /proc/slabinfo
  12870 /proc/net/rt_cache
ip_dst_cache       53327  57855

Eventually I get the dst_cache overflow errors and have to reboot.

Phil
