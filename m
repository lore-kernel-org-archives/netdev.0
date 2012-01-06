From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH 3/6] net: add support for per-paged-fragment destructors
Date: Fri, 6 Jan 2012 02:15:24 +0100
Message-ID: <20120106011524.GA10975@rere.qmqm.pl>
References: <1325783399.25206.413.camel@zakaz.uk.xensource.com>
 <1325783624-14601-3-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:35537 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756482Ab2AFBY3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jan 2012 20:24:29 -0500
Content-Disposition: inline
In-Reply-To: <1325783624-14601-3-git-send-email-ian.campbell@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 05, 2012 at 05:13:41PM +0000, Ian Campbell wrote:
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
> @@ -143,9 +143,16 @@ struct sk_buff;
> =20
>  typedef struct skb_frag_struct skb_frag_t;
> =20
> +struct skb_frag_destructor {
> +	atomic_t ref;
> +	int (*destroy)(void *data);
> +	void *data;
> +};
> +
[...]

What happened to removal of 'data' field from this structure?

ref: http://www.spinics.net/lists/netdev/msg179050.html

Best Regards,
Micha=B3 Miros=B3aw
