From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: Memory leak in 2.6.11-rc1?
Date: Thu, 27 Jan 2005 13:17:28 +0100 (CET)
Message-ID: <Pine.LNX.4.58.0501271315590.15253@tux.rsn.bth.se>
References: <20050121161959.GO3922@fi.muni.cz> <1106360639.15804.1.camel@boxen>
 <20050123091154.GC16648@suse.de> <20050123011918.295db8e8.akpm@osdl.org>
 <20050123095608.GD16648@suse.de> <20050123023248.263daca9.akpm@osdl.org>
 <20050123200315.A25351@flint.arm.linux.org.uk> <20050124114853.A16971@flint.arm.linux.org.uk>
 <20050125193207.B30094@flint.arm.linux.org.uk> <20050127082809.A20510@flint.arm.linux.org.uk>
 <20050127004732.5d8e3f62.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Russell King <rmk+lkml@arm.linux.org.uk>, torvalds@osdl.org,
        alexn@dsv.su.se, kas@fi.muni.cz, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20050127004732.5d8e3f62.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 27 Jan 2005, Andrew Morton wrote:

> Russell King <rmk+lkml@arm.linux.org.uk> wrote:
> >
> > This mornings magic numbers are:
> >
> >  3
> >  ip_dst_cache        1292   1485    256   15    1
>
> I just did a q-n-d test here: send one UDP frame to 1.1.1.1 up to
> 1.1.255.255.  The ip_dst_cache grew to ~15k entries and grew no further.
> It's now gradually shrinking.  So there doesn't appear to be a trivial
> bug..
>
> >  Is no one interested in the fact that the DST cache is leaking and
> >  eventually takes out machines?  I've had virtually zero interest in
> >  this problem so far.
>
> I guess we should find a way to make it happen faster.

I could be a refcount problem. I think Russell is using NAT, it could be
the MASQUERADE target if that is in use. A simple test would be to switch
to SNAT and try again if possible.

/Martin
