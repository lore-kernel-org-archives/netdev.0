From: Richard Weinberger <richard.weinberger@gmail.com>
Subject: Re: [PATCH] update consumers of MSG_MORE to recognize MSG_SENDPAGE_NOTLAST
Date: Tue, 26 Nov 2013 00:27:40 +0100
Message-ID: <CAFLxGvy+xtzYv9FJ1bDFr+apiNxJG+TML6=pz4faHRRj3yi0+Q@mail.gmail.com>
References: <20131125042633.GA4156@order.stressinduktion.org>
	<1385361388-2175-1-git-send-email-shawn@churchofgit.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	linux-crypto@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Tom Herbert <therbert@google.com>,
	"David S. Miller" <davem@davemloft.net>, stable@vger.kernel.org
To: Shawn Landden <shawn@churchofgit.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <1385361388-2175-1-git-send-email-shawn@churchofgit.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 25, 2013 at 7:36 AM, Shawn Landden <shawn@churchofgit.com> wrote:
> Commit 35f9c09fe (tcp: tcp_sendpages() should call tcp_push() once)
> added an internal flag MSG_SENDPAGE_NOTLAST, similar to
> MSG_MORE.
>
> algif_hash, algif_skcipher, and udp used MSG_MORE from tcp_sendpages()
> and need to see the new flag as identical to MSG_MORE.
>
> This fixes sendfile() on AF_ALG.
>
> v3: also fix udp
>
> Cc: Tom Herbert <therbert@google.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: <stable@vger.kernel.org> # 3.4.x + 3.2.x
> Reported-and-tested-by: Shawn Landden <shawnlandden@gmail.com>
> Original-patch: Richard Weinberger <richard@nod.at>
> Signed-off-by: Shawn Landden <shawn@churchofgit.com>

May I ask why you took over the my patch without even CC'in me nor
replying to the original
thread "[PATCH] pipe_to_sendpage: Ensure that MSG_MORE is set if we
set MSG_SENDPAGE_NOTLAST"?
You are acting very rude.

The discussion at the original thread is not done.
Does skcipher_sendpage() really also need fixing? or UDP?
I didn't send another patch because I'm waiting for Eric's answer first.

Thanks,
//richard

> ---
>  crypto/algif_hash.c     | 3 +++
>  crypto/algif_skcipher.c | 3 +++
>  net/ipv4/udp.c          | 3 +++
>  3 files changed, 9 insertions(+)
>
> diff --git a/crypto/algif_hash.c b/crypto/algif_hash.c
> index ef5356c..8502462 100644
> --- a/crypto/algif_hash.c
> +++ b/crypto/algif_hash.c
> @@ -114,6 +114,9 @@ static ssize_t hash_sendpage(struct socket *sock, struct page *page,
>         struct hash_ctx *ctx = ask->private;
>         int err;
>
> +       if (flags & MSG_SENDPAGE_NOTLAST)
> +               flags |= MSG_MORE;
> +
>         lock_sock(sk);
>         sg_init_table(ctx->sgl.sg, 1);
>         sg_set_page(ctx->sgl.sg, page, size, offset);
> diff --git a/crypto/algif_skcipher.c b/crypto/algif_skcipher.c
> index 6a6dfc0..a19c027 100644
> --- a/crypto/algif_skcipher.c
> +++ b/crypto/algif_skcipher.c
> @@ -378,6 +378,9 @@ static ssize_t skcipher_sendpage(struct socket *sock, struct page *page,
>         struct skcipher_sg_list *sgl;
>         int err = -EINVAL;
>
> +       if (flags & MSG_SENDPAGE_NOTLAST)
> +               flags |= MSG_MORE;
> +
>         lock_sock(sk);
>         if (!ctx->more && ctx->used)
>                 goto unlock;
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index 5944d7d..8bd04df 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -1098,6 +1098,9 @@ int udp_sendpage(struct sock *sk, struct page *page, int offset,
>         struct udp_sock *up = udp_sk(sk);
>         int ret;
>
> +       if (flags & MSG_SENDPAGE_NOTLAST)
> +               flags |= MSG_MORE;
> +
>         if (!up->pending) {
>                 struct msghdr msg = {   .msg_flags = flags|MSG_MORE };
>
> --
> 1.8.4.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Thanks,
//richard
