From: Luis Henriques <luis.henriques@canonical.com>
Subject: Re: [PATCH 3.19 and earlier] fib_rules: Fix dump_rules() not to exit
 early
Date: Mon, 19 Oct 2015 11:24:54 +0100
Message-ID: <20151019102454.GD3424@ares>
References: <1444066168-5566-1-git-send-email-roland@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, stable@vger.kernel.org,
	Roland Dreier <roland@purestorage.com>
To: Roland Dreier <roland@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:53514 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751776AbbJSKY4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 06:24:56 -0400
Content-Disposition: inline
In-Reply-To: <1444066168-5566-1-git-send-email-roland@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 05, 2015 at 10:29:28AM -0700, Roland Dreier wrote:
> From: Roland Dreier <roland@purestorage.com>
>=20
> Backports of 41fc014332d9 ("fib_rules: fix fib rule dumps across
> multiple skbs") introduced a regression in "ip rule show" - it ends u=
p
> dumping the first rule over and over and never exiting, because 3.19
> and earlier are missing commit 053c095a82cf ("netlink: make
> nlmsg_end() and genlmsg_end() void"), so fib_nl_fill_rule() ends up
> returning skb->len (i.e. > 0) in the success case.
>=20
> Fix this by checking the return code for < 0 instead of !=3D 0.
>=20
> Signed-off-by: Roland Dreier <roland@purestorage.com>
> ---
> Hi, this is needed for all stable trees earlier than 4.0 that have
> picked up 41fc014332d9; so far looks like at least 3.10.y and 3.14.y
> have made such releases.
>

Thanks Roland, I'm queuing this fix for the 3.16 kernel as well.

Cheers,
--
Lu=EDs


>  net/core/fib_rules.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
> index 627e517077e4..84340a2605ed 100644
> --- a/net/core/fib_rules.c
> +++ b/net/core/fib_rules.c
> @@ -606,7 +606,7 @@ static int dump_rules(struct sk_buff *skb, struct=
 netlink_callback *cb,
>  		err =3D fib_nl_fill_rule(skb, rule, NETLINK_CB(cb->skb).portid,
>  				       cb->nlh->nlmsg_seq, RTM_NEWRULE,
>  				       NLM_F_MULTI, ops);
> -		if (err)
> +		if (err < 0)
>  			break;
>  skip:
>  		idx++;
> --=20
> 2.5.0
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe stable" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
