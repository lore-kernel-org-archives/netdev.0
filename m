From: Julian Anastasov <ja@ssi.bg>
Subject: Re: sendto() bug?
Date: Tue, 27 Aug 2013 09:02:16 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1308270901120.1731@ja.ssi.bg>
References: <alpine.DEB.2.02.1308231257140.10771@optio.utah.ind.alcatel.com> <alpine.LFD.2.00.1308241105220.1641@ja.ssi.bg> <alpine.DEB.2.02.1308261319370.23968@optio.utah.ind.alcatel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Chris Clark <chris.clark@alcatel-lucent.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:53898 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752299Ab3H0F7K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Aug 2013 01:59:10 -0400
In-Reply-To: <alpine.DEB.2.02.1308261319370.23968@optio.utah.ind.alcatel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Mon, 26 Aug 2013, Chris Clark wrote:

> On Sat, 24 Aug 2013, Julian Anastasov wrote:
> > On Fri, 23 Aug 2013, Chris Clark wrote:
> > > In the same vein as 2ad5b9e4, I'm soliciting feedback on something
> > > similar for raw_sendmsg():
> [snip]
> 
> > 	So, something like
> > (inet->hdrincl ? FLOWI_FLAG_KNOWN_NH : 0) ?
> 
> 
> Many thanks.  This patch indeed appears to resolve the problem:
> 
> diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
> index dd44e0a..61e60d6 100644
> --- a/net/ipv4/raw.c
> +++ b/net/ipv4/raw.c
> @@ -571,7 +571,8 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
>  	flowi4_init_output(&fl4, ipc.oif, sk->sk_mark, tos,
>  			   RT_SCOPE_UNIVERSE,
>  			   inet->hdrincl ? IPPROTO_RAW : sk->sk_protocol,
> -			   inet_sk_flowi_flags(sk) | FLOWI_FLAG_CAN_SLEEP,
> +			   inet_sk_flowi_flags(sk) | FLOWI_FLAG_CAN_SLEEP |
> +			    (inet->hdrincl ? FLOWI_FLAG_KNOWN_NH : 0),

	Looks good,

Suggested-by: Julian Anastasov <ja@ssi.bg>

>  			   daddr, saddr, 0, 0);
> 
>  	if (!inet->hdrincl) {
> 
> 
> Chris

Regards

--
Julian Anastasov <ja@ssi.bg>
