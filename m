From: Andi Kleen <ak@muc.de>
Subject: Re: issue with new TCP TSO stuff
Date: Thu, 12 May 2005 16:13:05 +0200
Message-ID: <m1sm0sttvy.fsf@muc.de>
References: <20050511.223036.39664020.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050511.223036.39664020.davem@davemloft.net> (David S.
 Miller's message of "Wed, 11 May 2005 22:30:36 -0700 (PDT)")
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"David S. Miller" <davem@davemloft.net> writes:
>
> This shows up in testing where the connection is application limited.
> For example, an "scp" goes more slowly over TSO now, there are less
> cpu cycles available for the encryption.
>
> It's tricky to come up with a scheme to fix this.  I would love to be
> able to not do the page grabs/releases in the actual TSO frame.  I
> really haven't come up with a clean way to do that however.

Are you sure a few atomic_inc/dec are really causing noticeable
slowdown? That would surprise me unless you have lots of cache line
bouncing on a MP system.

What CPU did you test it on? Does it happen with only a single CPU?
And did you actually see them in some profile?

Assuming the struct page is in cache the P4 core is the slowest at
that that I know, but even on that one it should be in the noise on
the other overhead of talking to a NIC on a PCI bus.

Perhaps it is something else..

-Andi
