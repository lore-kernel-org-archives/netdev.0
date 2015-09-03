From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Thu, 3 Sep 2015 12:48:15 -0700
Message-ID: <CA+55aFy9L9U+bkk_VLRdWmepRH8LRkDw1sBo8t-byKUTZKWwBw@mail.gmail.com>
References: <20150902.223522.1792493140210966693.davem@davemloft.net>
	<CA+55aFx=xh4+vCNOgwXyfeV-t=6anXimqBxH_i71RjYy+Gy9-w@mail.gmail.com>
	<20150903.104032.767889134756094076.davem@davemloft.net>
	<CA+55aFxtD2VYW2R0JwjFkZkvzQzcN7qK3m6ReR+BBXtfyDHx7g@mail.gmail.com>
	<1441305296.9666.14.camel@perches.com>
	<alpine.DEB.2.02.1509032121120.2035@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>,
	Lorenzo Bianconi <lorenzo.bianconi83@gmail.com>,
	Johannes Berg <johannes.berg@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1509032121120.2035@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 3, 2015 at 12:32 PM, Julia Lawall <julia.lawall@lip6.fr> wrote:
>
> I find 518 occurrences of a function parameter declaration that contains
> an explicit size.  But only the sizeof(mcs_mask) where there is a sizeof
> on such a parameter.  I also checked for ARRAY_SIZE on such parameters,
> and didn't find any occurrences of that either.

Are there any cases of multi-dimensional arrays? Because those
actually have semantic meaning outside of sizeof(), just in things
like adding offsets.

Eg something like

     int fn(int a[][10])

ends up being equivalent to something like

     int fn(int (*a)[10])

and "a+1" is actually 40 bytes ahead of "a", so it does *not* act like
an "int *".

(And I might have screwed that up mightily - C multidimensional arrays
and the conversions to pointers are really easy to get confused about.
Which is why I hope we don't have them)

                  Linus
