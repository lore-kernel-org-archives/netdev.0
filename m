From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH-2.6.0-tiny] "uninline" {lock,release}_sock
Date: Sun, 28 Dec 2003 12:42:25 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031228184225.GT18208@waste.org>
References: <20031228075426.GB24351@conectiva.com.br> <Pine.LNX.4.58.0312280017060.2274@home.osdl.org> <20031228012329.43003de5.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@osdl.org>, acme@conectiva.com.br,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20031228012329.43003de5.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Dec 28, 2003 at 01:23:29AM -0800, David S. Miller wrote:
> On Sun, 28 Dec 2003 00:23:07 -0800 (PST)
> Linus Torvalds <torvalds@osdl.org> wrote:
> 
> > Function calls aren't all that expensive, especially with FASTCALL() etc 
> > to show that you don't have to follow the common calling conventions. 
> > Right now I think FASTCALL() only matters on x86, but some other 
> > architectures could make it mean "smaller call clobbered list" or similar.
> > 
> > Have you benchmarked with the smaller kernel? 

The primary benchmark for -tiny is how much space it frees up, which
is very straightforward. More generally, I think we've got something
of a crisis on our hands in terms of benchmarking as caching
architectures are making microbenchmark results worse than worthless
for real life and changes like these are often lost in the noise for
larger benchmarks.
 
> To be honest I think {lock,release}_sock() should both be uninlined
> always.
> 
> It almost made sense to inline these things before the might_sleep()
> was added, now it definitely makes no sense.

For the purposes of my -tiny tree, I'd like to make every new feature
conditional as an aid to footprint measurement, benchmarking, regression
testing, etc. When I start feeding these patches to mainline, they can
be made unconditional as is warranted.

-- 
Matt Mackall : http://www.selenic.com : Linux development and consulting
