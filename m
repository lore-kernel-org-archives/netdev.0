From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Tue, 10 Feb 2015 18:01:32 -0800
Message-ID: <CA+55aFwdXNYMWGGNsAzyRiZ60HE_G=CJesLShPHGxtADJd2TPQ@mail.gmail.com>
References: <20150209.191601.1373941323785500419.davem@davemloft.net>
	<CA+55aFxskyQ2CkLJ8c_LDkjTY+kKSJ5N6JPjhewGYXsXcHg7nw@mail.gmail.com>
	<20150209.205209.1524645061817000265.davem@davemloft.net>
	<CA+55aFxrGRjL_d=aCZQ0sNC+pfW8nYDLb4KkUVAme5oHmjBjTw@mail.gmail.com>
	<CA+55aFwxuMcNPU-C5p2hSWuNhJW+DOi3Py0NQ--Rw9_bv3md2w@mail.gmail.com>
	<CA+55aFzJNNDi0YKXnNYF=ccYvXALRxzngiV1tARd6CdCimVRYg@mail.gmail.com>
	<CA+55aFyqFrf9cRQ7wDSDLNraR+meZ-=dwWdDThtpPtrFFqrcGw@mail.gmail.com>
	<20150211014502.GB29656@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150211014502.GB29656@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 10, 2015 at 5:45 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
>
> Could you check if
>
> diff --git a/crypto/af_alg.c b/crypto/af_alg.c
> index eb78fe8..5b11d64 100644
> --- a/crypto/af_alg.c
> +++ b/crypto/af_alg.c
> @@ -348,7 +348,7 @@ int af_alg_make_sg(struct af_alg_sgl *sgl, struct iov_iter *iter, int len)
>         if (n < 0)
>                 return n;
>
> -       npages = PAGE_ALIGN(off + n);
> +       npages = DIV_ROUND_UP(off + n, PAGE_SIZE);
>         if (WARN_ON(npages == 0))
>                 return -EINVAL;
>
> on top of what went into Dave's tree is enough to fix what you are seeing?

So quite frankly, considering that we already know that 'used' was
also calculated wrong (it stays at zero) and that the one-liner above
is not sufficient on its own, by now I'd like somebody with an actual
test-case to check this thing out., and send me a proper tested patch.
That somebody preferably being you.

Are there no tests for that crypto interface?

Also, I'm unhappy that you made these unrelated and broken changes at
all. Both wrt 'used' and this 'npages' thing, the original code wasn't
wrong, and the pointless changes to correct code not only broke
things, but had nothing to do with the iovec conversion that was the
stated reason for the commit.

Grr. I really hate it when I find bugs during the merge window. My
test environment is *not* odd. If _I_ end up being the one finding the
bugs, that means that things must have gotten basically no testing at
all.

I spend a *lot* of time during the merge window doing "make
allmodconfig" builds and trying to actually also boot the resulting
kernel before pushing things out. But it does mean that when I *do*
catch it, I'd like the cost of fixing it be on the person who
introduced the problem, rather than me spending even *more* time on
this.

                           Linus
