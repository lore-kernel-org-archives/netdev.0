From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Wed, 28 Oct 2015 16:08:29 -0700
Message-ID: <1446073709.7476.93.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1445991236.7476.59.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151028123543.GB22011@ZenIV.linux.org.uk>
	 <1446038672.7476.65.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1446043677.7476.68.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151028211347.GC22011@ZenIV.linux.org.uk>
	 <1446068668.7476.89.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151028223330.GD22011@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, stephen@networkplumber.org,
	netdev@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	dhowells@redhat.com, linux-fsdevel@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20151028223330.GD22011@ZenIV.linux.org.uk>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-10-28 at 22:33 +0000, Al Viro wrote:
> On Wed, Oct 28, 2015 at 02:44:28PM -0700, Eric Dumazet wrote:
> 
> > Well, all this complexity goes away with a O_FD_FASTALLOC /
> > SOCK_FD_FASTALLOC bit in various fd allocations, which specifically
> > tells the kernel we do not care getting the lowest possible fd as POSIX
> > mandates.
> 
> ... which won't do a damn thing for existing userland.

For the userland that need +5,000,000 socket, I can tell you they are
using this flag as soon they are aware it exists ;)

> 
> > Except for legacy stuff and stdin/stdout/stderr games, I really doubt
> > lot of applications absolutely rely on the POSIX thing...
> 
> We obviously can't turn that into default behaviour, though.  BTW, what
> distribution do you have in mind for those random descriptors?  Uniform
> on [0,INT_MAX] is a bad idea for obvious reasons - you'll blow the
> memory footprint pretty soon...

Simply [0 , fdt->max_fds] is working well in most cases.



