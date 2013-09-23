From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] xfrm: Simplify SA looking up when using wildcard
 source address
Date: Mon, 23 Sep 2013 23:46:28 +0400
Message-ID: <52409A94.7090308@cogentembedded.com>
References: <1379927917-17365-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: steffen.klassert@secunet.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:39640 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752095Ab3IWTqa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 15:46:30 -0400
Received: by mail-lb0-f170.google.com with SMTP id w7so3093627lbi.1
        for <netdev@vger.kernel.org>; Mon, 23 Sep 2013 12:46:28 -0700 (PDT)
In-Reply-To: <1379927917-17365-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 09/23/2013 01:18 PM, Fan Du wrote:

> I'm not quite sure I get this "wildcard source address" right,
> IMHO if a host needs to protect every traffic for a given remote host=
,
> then the source address is wildcard address, i.e. all ZEROs.
> (Please correct me if I'm bloodly wrong=E3=80=82=E3=80=82=E3=80=82)

> Here is the argument if above statement stands true:
> __xfrm4/6_state_addr_check is a four steps check, all we need to do
> is checking whether the destination address match. Passing saddr from
> flow is worst option, as the checking needs to reach the fourth step.

> So, simply this process by only checking destination address only whe=
n
> using wildcard source address for looking up SAs.

> Signed-off-by: Fan Du <fan.du@windriver.com>
> ---
>   include/net/xfrm.h    |   31 +++++++++++++++++++++++++++++++
>   net/xfrm/xfrm_state.c |    2 +-
>   2 files changed, 32 insertions(+), 1 deletion(-)

> diff --git a/include/net/xfrm.h b/include/net/xfrm.h
> index e253bf0..fdb9343 100644
> --- a/include/net/xfrm.h
> +++ b/include/net/xfrm.h
> @@ -1282,6 +1282,37 @@ xfrm_state_addr_check(const struct xfrm_state =
*x,
>   }
>
>   static __inline__ int
> +__xfrm4_state_daddr_check(const struct xfrm_state *x,
> +                                const xfrm_address_t *daddr)
> +{
> +        return ((daddr->a4 =3D=3D x->id.daddr.a4) ? 1 : 0);

    () not needed around the *return* expression, and ?: not needed too=
=2E

WBR, Sergei
