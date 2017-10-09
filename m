From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v2] netlink: do not set cb_running if dump's start() errs
Date: Mon, 09 Oct 2017 14:31:29 +0200
Message-ID: <1507552289.26041.52.camel@sipsolutions.net>
References: <CAHmME9qK84HT6DEC2Z3q-E+J8AtNSp_7GNAcjWSSsKnxX0eAkA@mail.gmail.com>
         <20171009121451.26815-1-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "Jason A. Donenfeld" <Jason@zx2c4.com>, davem@davemloft.net,
        Netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171009121451.26815-1-Jason@zx2c4.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2017-10-09 at 14:14 +0200, Jason A. Donenfeld wrote:
> It turns out that multiple places can call netlink_dump(), which
> means
> it's still possible to dereference partially initialized values in
> dump() that were the result of a faulty returned start().
> 
> This fixes the issue by calling start() _before_ setting cb_running
> to
> true, so that there's no chance at all of hitting the dump() function
> through any indirect paths.
> 
> It also moves the call to start() to be when the mutex is held. This
> has
> the nice side effect of serializing invocations to start(), which is
> likely desirable anyway. It also prevents any possible other races
> that
> might come out of this logic.

I'm not necessarily sure it's _nice_, but I do think it doesn't matter,
so that's just splitting hairs. If you do have a genl family with
parallel_ops, you'd better be prepared to handle parallel things, and
then this could also be in parallel :-)

> In testing this with several different pieces of tricky code to
> trigger
> these issues, this commit fixes all avenues that I'm aware of.
> 
> Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>

Reviewed-by: Johannes Berg <johannes@sipsolutions.net>

johannes
