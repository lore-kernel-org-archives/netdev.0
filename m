From: Simon Kirby <sim@netnation.com>
Subject: Re: Route cache performance under stress
Date: Sun, 8 Jun 2003 23:52:11 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030609065211.GB20613@netnation.com>
References: <20030608.224446.78724665.davem@redhat.com> <001501c32e4b$35d67d60$4a00000a@badass> <20030608.230332.48514434.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xerox@foonet.net, fw@deneb.enyo.de, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030608.230332.48514434.davem@redhat.com>
List-Id: netdev.vger.kernel.org

On Sun, Jun 08, 2003 at 11:03:32PM -0700, David S. Miller wrote:

>    I'd love to test this out.. If it could do full gigabit line rate with
>    random ips that would be soooooooo nice :>

Agreed. :)

> It isn't impossible with the current design, that I am
> quire sure of.
> 
> Here is a simple idea, make the routing cache miss case steal
> an entry sitting at the end of the hash chain this new one will
> map to.  It only steals entries which have not been recently used.

I just asked whether this was possible in a previous email, but you must
have missed it.  I am seeing a lot of memory management stuff in
profiles, so I think recycling routing cache entries (if only when the
table is full and the garbage collector would otherwise need to run)
would be very helpful.

Is it possible to get a good guess of what cache entry to recycle without
walking for a while or without some kind of LRU?

> The big problem area on SMP is fib_validate_source.  I'm sure some
> clear thinking can wipe that off the profiles too.

Not running the important stuff with SMP yet, so I don't care about this
at the moment. O:)

Simon-
