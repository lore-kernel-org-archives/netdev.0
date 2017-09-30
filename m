From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] netlink: do not proceed if dump's start() errs
Date: Sat, 30 Sep 2017 07:27:37 +0100 (WEST)
Message-ID: <20170930.072737.128573396497381459.davem@davemloft.net>
References: <CAHmME9oA+dE3eOCTWweJjZGL4sog30JShoCJoWaPn4JV7h3auA@mail.gmail.com>
        <20170927224144.1749-1-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes.berg@intel.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, johannes@sipsolutions.net
To: Jason@zx2c4.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170927224144.1749-1-Jason@zx2c4.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Thu, 28 Sep 2017 00:41:44 +0200

> Drivers that use the start method for netlink dumping rely on dumpit not
> being called if start fails. For example, ila_xlat.c allocates memory
> and assigns it to cb->args[0] in its start() function. It might fail to
> do that and return -ENOMEM instead. However, even when returning an
> error, dumpit will be called, which, in the example above, quickly
> dereferences the memory in cb->args[0], which will OOPS the kernel. This
> is but one example of how this goes wrong.
> 
> Since start() has always been a function with an int return type, it
> therefore makes sense to use it properly, rather than ignoring it. This
> patch thus returns early and does not call dumpit() when start() fails.
> 
> Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
> Cc: Johannes Berg <johannes@sipsolutions.net>

Johannes, this looks straightforward to me, but please would you give
it a quick review?

Thank you.
