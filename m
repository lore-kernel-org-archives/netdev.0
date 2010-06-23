From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next-2.6] netfilter: allow nf_tproxy_core module to
 be removed
Date: Wed, 23 Jun 2010 20:46:11 +0200
Message-ID: <20100623184611.GG27132@Chamillionaire.breakpoint.cc>
References: <20100623183503.GE2687@psychotron.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, kaber@trash.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:47589 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751366Ab0FWSqN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jun 2010 14:46:13 -0400
Content-Disposition: inline
In-Reply-To: <20100623183503.GE2687@psychotron.bos.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko <jpirko@redhat.com> wrote:
> diff --git a/net/netfilter/nf_tproxy_core.c b/net/netfilter/nf_tproxy_core.c
> index 5490fc3..ec6737c 100644
> --- a/net/netfilter/nf_tproxy_core.c
> +++ b/net/netfilter/nf_tproxy_core.c
> @@ -89,7 +89,12 @@ static int __init nf_tproxy_init(void)
>  	return 0;
>  }
>  
> +static void __exit nf_tproxy_exit(void)
> +{
> +}
> +
>  module_init(nf_tproxy_init);
> +module_exit(nf_tproxy_exit);

tproxy assigns skb->destructor, what prevents module unload while such skbs may
still be around?
