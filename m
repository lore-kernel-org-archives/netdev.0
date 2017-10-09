From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] netlink: do not set cb_running if dump's start()
 errs
Date: Mon, 09 Oct 2017 10:29:08 -0700 (PDT)
Message-ID: <20171009.102908.912133092174394094.davem@davemloft.net>
References: <CAHmME9qK84HT6DEC2Z3q-E+J8AtNSp_7GNAcjWSSsKnxX0eAkA@mail.gmail.com>
        <20171009121451.26815-1-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Jason@zx2c4.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171009121451.26815-1-Jason@zx2c4.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Mon,  9 Oct 2017 14:14:51 +0200

> It turns out that multiple places can call netlink_dump(), which means
> it's still possible to dereference partially initialized values in
> dump() that were the result of a faulty returned start().
> 
> This fixes the issue by calling start() _before_ setting cb_running to
> true, so that there's no chance at all of hitting the dump() function
> through any indirect paths.
> 
> It also moves the call to start() to be when the mutex is held. This has
> the nice side effect of serializing invocations to start(), which is
> likely desirable anyway. It also prevents any possible other races that
> might come out of this logic.
> 
> In testing this with several different pieces of tricky code to trigger
> these issues, this commit fixes all avenues that I'm aware of.
> 
> Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>

Applied and queued up for -stable.
