From: Erik Hensema <erik@hensema.net>
Subject: Re: 2.6.0: something is leaking memory
Date: Mon, 5 Jan 2004 19:14:42 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040105181442.GA13674@bender.home.hensema.net>
References: <slrnbvgohn.1pb.erik@dexter.hensema.net> <Pine.LNX.4.58.0401041257290.2162@home.osdl.org> <slrnbvh1hd.jl6.erik@dexter.hensema.net> <Pine.LNX.4.58.0401041826400.2162@home.osdl.org> <20040104204834.40b6ca51.davem@redhat.com>
Reply-To: erik@hensema.net
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040104204834.40b6ca51.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Jan 04, 2004 at 08:48:34PM -0800, David S. Miller wrote:
> On Sun, 4 Jan 2004 18:30:21 -0800 (PST)
> Linus Torvalds <torvalds@osdl.org> wrote:
> 
> > You've got 19 _megabytes_ allocated to "tcp6_sock", and they are all 
> > marked as "active". That's almost certainly the leaking bug.
> > 
> > Everything else looks reasonably normal.
>  ...
> > David?
> 
> Fixed by changeset 1.1496.16.1 which is in 2.6.1-rc1

Are you sure?

tcp6_sock           1110   1136   1024    4    1 : tunables   54   27    0
: slabdata    284    284      0

dexter:~ # netstat --inet6 | wc -l
     21
dexter:~ # uptime
 19:13:22 up  4:36,  1 user,  load average: 0.02, 0.08, 0.09

This is 2.6.1-rc1.

I can't say anything definitive until after a few days of uptime, but it
sure seems the leak is still there.
-- 
Erik Hensema (erik@hensema.net)
