From: Erik Hensema <erik@hensema.net>
Subject: Re: 2.6.0: something is leaking memory
Date: Tue, 6 Jan 2004 20:36:15 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040106193615.GA4544@bender.home.hensema.net>
References: <slrnbvgohn.1pb.erik@dexter.hensema.net> <Pine.LNX.4.58.0401041257290.2162@home.osdl.org> <slrnbvh1hd.jl6.erik@dexter.hensema.net> <Pine.LNX.4.58.0401041826400.2162@home.osdl.org> <20040104204834.40b6ca51.davem@redhat.com> <20040106155933.GA3373@bender.home.hensema.net> <20040106095909.7243b2ce.davem@redhat.com>
Reply-To: erik@hensema.net
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@osdl.org, netdev@oss.sgi.com, acme@conectiva.com.br
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040106095909.7243b2ce.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jan 06, 2004 at 09:59:09AM -0800, David S. Miller wrote:
> On Tue, 6 Jan 2004 16:59:34 +0100
> Erik Hensema <erik@hensema.net> wrote:
> 
> > David: are you sure it was fixed in rc1?
> > 
> > It doesn't seem to be in -rc2 either.
> > 
> > This is after 26 hours uptime:
> > 
> > tcp6_sock           6246   6248   1024    4    1 : tunables   54   27    0
> > : slabdata   1562   1562      0
> 
> Someone mentioned about a bug in the userland program you're
> using that is openning these sockets?  Something about leaving sockets
> not closed.

That's correct. I suspect that this exposes the leak in the kernel more
promimently than on other systems.

The leak is in nscd, it doesn't properly close sockets to my LDAP server.
This is not a kernel problem I think, because it also leaks in 2.4.x. The
kernelspace leak however is not in 2.4, only in 2.6.

I'm restarting nscd in cron every night, which makes the CLOSE_WAIT sockets
go away. However the kernel resources are not freed it seems.
-- 
Erik Hensema (erik@hensema.net)
