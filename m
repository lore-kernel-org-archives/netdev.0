From: Mathias Krause <minipli@googlemail.com>
Subject: Re: [patch -mainline] af_key: more info leaks in pfkey messages
Date: Thu, 25 Jul 2013 09:15:15 +0200
Message-ID: <CA+rthh89e+L6FRJbd5T=ab8ayO=W7qXOhMbt49WLadmXOztLsQ@mail.gmail.com>
References: <20130724103956.GA30345@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:46270 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753096Ab3GYHPR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 03:15:17 -0400
In-Reply-To: <20130724103956.GA30345@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24 July 2013 12:39, Dan Carpenter <dan.carpenter@oracle.com> wrote:
>
> This is inspired by a5cc68f3d6 "af_key: fix info leaks in notify
> messages".  There are some struct members which don't get initialized
> and could disclose small amounts of private information.
>
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
> I'm at the "monkey see, monkey do" level of understanding this code so
> let me know if I've missed something.
>
> diff --git a/net/key/af_key.c b/net/key/af_key.c
> index 456b262..e939d32 100644
> --- a/net/key/af_key.c
> +++ b/net/key/af_key.c
> @@ -2081,6 +2081,7 @@ static int pfkey_xfrm_policy2msg(struct sk_buff *skb, const struct xfrm_policy *
>                         pol->sadb_x_policy_type = IPSEC_POLICY_NONE;
>         }
>         pol->sadb_x_policy_dir = dir+1;
> +       pol->sadb_x_policy_reserved = 0;
>         pol->sadb_x_policy_id = xp->index;
>         pol->sadb_x_policy_priority = xp->priority;
>
> @@ -3137,7 +3138,9 @@ static int pfkey_send_acquire(struct xfrm_state *x, struct xfrm_tmpl *t, struct
>         pol->sadb_x_policy_exttype = SADB_X_EXT_POLICY;
>         pol->sadb_x_policy_type = IPSEC_POLICY_IPSEC;
>         pol->sadb_x_policy_dir = XFRM_POLICY_OUT + 1;
> +       pol->sadb_x_policy_reserved = 0;
>         pol->sadb_x_policy_id = xp->index;
> +       pol->sadb_x_policy_priority = 0;
>
>         /* Set sadb_comb's. */
>         if (x->id.proto == IPPROTO_AH)
> @@ -3525,6 +3528,7 @@ static int pfkey_send_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
>         pol->sadb_x_policy_exttype = SADB_X_EXT_POLICY;
>         pol->sadb_x_policy_type = IPSEC_POLICY_IPSEC;
>         pol->sadb_x_policy_dir = dir + 1;
> +       pol->sadb_x_policy_reserved = 0;
>         pol->sadb_x_policy_id = 0;
>         pol->sadb_x_policy_priority = 0;
>

Looks good to me. All end up being send to userland over the PF_KEY interface.

Acked-by: Mathias Krause <minipli@googlemail.com>
