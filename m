From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v3 net-next 3/4] tls: kernel TLS support
Date: Fri, 16 Jun 2017 13:56:32 -0700
Message-ID: <20170616135632.67e2bb9b@xeon-e3>
References: <cover.1497465295.git.davejwatson@fb.com>
        <20170614183739.GA80368@davejwatson-mba.dhcp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ilya Lesokhin <ilyal@mellanox.com>,
        Aviad Yehezkel <aviadye@mellanox.com>,
        Boris Pismenny <borisp@mellanox.com>,
        Liran Liss <liranl@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Tom Herbert <tom@herbertland.com>,
        <herbert@gondor.apana.org.au>, <linux-crypto@vger.kernel.org>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        <nmav@gnutls.org>, <fridolin.pokorny@gmail.com>
To: Dave Watson <davejwatson@fb.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20170614183739.GA80368@davejwatson-mba.dhcp.thefacebook.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 14 Jun 2017 11:37:39 -0700
Dave Watson <davejwatson@fb.com> wrote:

> +
> +static inline struct tls_context *tls_get_ctx(const struct sock *sk)
> +{
> +	struct inet_connection_sock *icsk = inet_csk(sk);
> +
> +	return icsk->icsk_ulp_data;
> +}
> +
> +static inline struct tls_sw_context *tls_sw_ctx(
> +		const struct tls_context *tls_ctx)
> +{
> +	return (struct tls_sw_context *)tls_ctx->priv_ctx;
> +}
> +
> +static inline struct tls_offload_context *tls_offload_ctx(
> +		const struct tls_context *tls_ctx)
> +{
> +	return (struct tls_offload_context *)tls_ctx->priv_ctx;
> +}
> +

Since priv_ctx is void *, casts here are unnecessary.
