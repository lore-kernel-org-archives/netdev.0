From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v2] netlink: do not proceed if dump's start() errs
Date: Sat, 30 Sep 2017 08:56:10 +0200
Message-ID: <1506754570.3568.3.camel@sipsolutions.net>
References: <CAHmME9oA+dE3eOCTWweJjZGL4sog30JShoCJoWaPn4JV7h3auA@mail.gmail.com>
         <20170927224144.1749-1-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
To: "Jason A. Donenfeld" <Jason@zx2c4.com>, davem@davemloft.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170927224144.1749-1-Jason@zx2c4.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-09-28 at 00:41 +0200, Jason A. Donenfeld wrote:
> Drivers that use the start method for netlink dumping rely on dumpit
> not
> being called if start fails. For example, ila_xlat.c allocates memory
> and assigns it to cb->args[0] in its start() function. It might fail
> to
> do that and return -ENOMEM instead. However, even when returning an
> error, dumpit will be called, which, in the example above, quickly
> dereferences the memory in cb->args[0], which will OOPS the kernel.
> This
> is but one example of how this goes wrong.
> 
> Since start() has always been a function with an int return type, it
> therefore makes sense to use it properly, rather than ignoring it.
> This
> patch thus returns early and does not call dumpit() when start()
> fails.
> 
> Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>

Reviewed-by: Johannes Berg <johannes@sipsolutions.net>


FWIW, I found another (indirect, via genetlink, like ila_xlat.c) in-
tree user that cares and expects the correct failure behaviour:

net/ipv6/seg6.c
	.start  = seg6_genl_dumphmac_start,

which can also have memory allocation failures. No others appear to
exist, afaict.

Either way, perhaps it's worth sending this to stable for that reason.

johannes
