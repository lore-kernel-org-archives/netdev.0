From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH][RFC] Netconsole debugging tool for 2.6
Date: Tue, 12 Aug 2003 12:39:17 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030812173917.GM31810@waste.org>
References: <3F38F5EC.2060003@jburgess.uklinux.net> <20030812163311.GL31810@waste.org> <20030812170920.GB24774@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jon Burgess <mplayer@jburgess.uklinux.net>,
   linux kernel <linux-kernel@vger.kernel.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20030812170920.GB24774@gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Aug 12, 2003 at 01:09:20PM -0400, Jeff Garzik wrote:
> On Tue, Aug 12, 2003 at 11:33:11AM -0500, Matt Mackall wrote:
> > On Tue, Aug 12, 2003 at 03:13:00PM +0100, Jon Burgess wrote:
> > > Matt Mackall wrote:
> > > > I've decided to take a stab at resurrecting Ingo's netconsole patch.
> > > 
> > > Is this different from the netdump patch which RedHat include in their 
> > > kernel?
> > > 
> > > The RH kernel patch is at
> > > http://www.kernelnewbies.org/kernels/rh9/SOURCES/linux-2.4.18-netdump.patch
> > 
> > Ahh, so that's what's become of it.
> > 
> > Theirs:
> > - does crashdumps
> > - does syslog without levels
> > - has hooks for receive
> > 
> > Mine:
> > - works in 2.6
> > - has non-appalling configuration
> > - works as a built-in and is available earlier in boot
> > - does syslog with levels (haven't posted this though)
> 
> netconsole does syslog with levels, too.  I agree netdump/netconsole
> have complete awful configuration.  I was thinking netlink would be a
> good configurator.

My personal goal is to have it configured in time to catch stuff in
the boot process so I can avoid plugging into the serial console,
which means everything on the command line. So I've got code to parse
the following:

netconsole=[src-port]@[src-ip]/[<dev>],[tgt-port]@<tgt-ip>/[tgt-macaddr]

> The kernel printk <foo> prefixes map into syslog quite nicely.

..and are stripped by printk before the console code is called. The
netdump patch logs everything at level 5:

+               send_syslog_skb(dev, syslog_line, syslog_chars, 5);

My patch adds another entry to console struct for writing with levels.
And adds hostname to messages. Still needs timestamp.
 
> In any case, there is my own active effort into cleaning up netdump to
> be less x86-specific, and get it ready for mainline.
>
> Maybe we can start discussing converging all these implementations on
> netdev@oss.sgi.com?  (that's where the networking developers live)

Not sure that's the right place for it, simply because that's the one
group of people it's not terribly useful for. Especially when I start
talking about hooking it up to kgdb. And the network bits are pretty
much there already.

-- 
Matt Mackall : http://www.selenic.com : of or relating to the moon
