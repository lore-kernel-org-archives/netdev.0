From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH 1/4] net: add support for per-paged-fragment destructors
Date: Wed, 9 Nov 2011 16:33:00 +0100
Message-ID: <20111109153300.GA11617@rere.qmqm.pl>
References: <1320850895.955.172.camel@zakaz.uk.xensource.com>
 <1320850927-30240-1-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:57987 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751779Ab1KIPdE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Nov 2011 10:33:04 -0500
Content-Disposition: inline
In-Reply-To: <1320850927-30240-1-git-send-email-ian.campbell@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 09, 2011 at 03:02:04PM +0000, Ian Campbell wrote:
> Entities which care about the complete lifecycle of pages which they =
inject
> into the network stack via an skb paged fragment can choose to set th=
is
> destructor in order to receive a callback when the stack is really fi=
nished
> with a page (including all clones, retransmits, pull-ups etc etc).
[...]
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -139,9 +139,16 @@ struct sk_buff;
> =20
>  typedef struct skb_frag_struct skb_frag_t;
> =20
> +struct skb_frag_destructor {
> +	atomic_t ref;
> +	int (*destroy)(void *data);
> +	void *data;
> +};
> +
>  struct skb_frag_struct {
>  	struct {
>  		struct page *p;
> +		struct skb_frag_destructor *destructor;
>  	} page;

You can get rid of the data field of skb_frag_destructor: if destroy() =
gets
pointer to the destroyed struct skb_frag_set_destructor, its users can
get at containing struct via container_of() if needed and the memory
pointed to by data won't have to be managed separately.

Nice work, BTW!

Best Regards,
Micha=B3 Miros=B3aw
