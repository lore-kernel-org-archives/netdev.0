From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [IPV6] Close small race in ip6_del_rt
Date: Tue, 9 Nov 2004 21:38:19 -0800
Message-ID: <20041109213819.1e996045.davem@davemloft.net>
References: <20041106103449.GA18569@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20041106103449.GA18569@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 6 Nov 2004 21:34:49 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> There is a small SMP race in ip6_del_rt where we maybe dereferencing a dst
> that has been freed.  This patch fixes it.

Looks good, applied.  Thanks.

There are certain routines, such as fib6_add() and fib_del()
for which it would be nice to have dst/rt refcounting
descriptions in comments.  Then we could:

1) Verify they actually provide that behavior.
2) Make sure callers handle this behavior properly.

I mention this because I had to read the entirety of
fib6_add() to verify some dst refcounting code paths
in the ipv6 stack last week.
