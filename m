From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6] net: comment rx_handler results
Date: Sat, 05 Mar 2011 16:27:52 +0100
Message-ID: <4D725678.2020706@gmail.com>
References: <1299320969-7951-1-git-send-email-jpirko@redhat.com> <1299320969-7951-8-git-send-email-jpirko@redhat.com> <1299329330.4277.97.camel@localhost> <20110305151331.GE8573@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	andy@greyhouse.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:42497 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750821Ab1CEP14 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Mar 2011 10:27:56 -0500
Received: by wwb22 with SMTP id 22so3676971wwb.1
        for <netdev@vger.kernel.org>; Sat, 05 Mar 2011 07:27:55 -0800 (PST)
In-Reply-To: <20110305151331.GE8573@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/03/2011 16:13, Jiri Pirko a =E9crit :
>
> Signed-off-by: Jiri Pirko<jpirko@redhat.com>
> ---
>   include/linux/netdevice.h |   12 ++++++++----
>   1 files changed, 8 insertions(+), 4 deletions(-)
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 48a9638..26e03f9 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -391,10 +391,14 @@ enum gro_result {
>   typedef enum gro_result gro_result_t;
>
>   enum rx_handler_result {
> -	RX_HANDLER_CONSUMED,
> -	RX_HANDLER_ANOTHER,
> -	RX_HANDLER_EXACT,
> -	RX_HANDLER_PASS,
> +	RX_HANDLER_CONSUMED,	/* skb was consumed by rx_handler,
> +				   do not process it further. */
> +	RX_HANDLER_ANOTHER,	/* Do another round in receive path.
> +				   This is indicated in case skb->dev
> +				   was changed by rx_handler */
> +	RX_HANDLER_EXACT,	/* Force exact delivery, no wildcard */
> +	RX_HANDLER_PASS,	/* Do nothing, pass the skb as if
> +				   no rx_handler was called */

Changing skb->dev should always cause another_round.

So, RX_HANDLER_ANOTHER could be removed and replaced with a test for sk=
b->dev change, with=20
RX_HANDER_EXACT and RX_HANDLER_PASS.

 > +	RX_HANDLER_CONSUMED,	/* skb was consumed by rx_handler,
 > +				   do not process it further. */
 > +	RX_HANDLER_EXACT,	/* Force exact delivery, no wildcard */
 > +	RX_HANDLER_PASS,	/* Do normal (wildcard and exact) delivery */

And any rx_handler returning RX_HANDLER_EXACT should cause exact delive=
ry, even if possible next=20
rx_handlers return RX_HANDLER_PASS.

	Nicolas.
