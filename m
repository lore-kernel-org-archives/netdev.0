From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 5/5] ipv6: RFC 4884 partial support for SIT/GRE
 tunnels
Date: Sat, 18 Jun 2016 21:03:29 -0700
Message-ID: <1466309009.6850.10.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1466292400-3638-1-git-send-email-edumazet@google.com>
	 <1466292400-3638-6-git-send-email-edumazet@google.com>
	 <20160618.205448.2083694904305197335.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org,
	ghorbel@pivasoftware.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:33101 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750720AbcFSEDc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2016 00:03:32 -0400
Received: by mail-pf0-f181.google.com with SMTP id i123so39235355pfg.0
        for <netdev@vger.kernel.org>; Sat, 18 Jun 2016 21:03:31 -0700 (PDT)
In-Reply-To: <20160618.205448.2083694904305197335.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2016-06-18 at 20:54 -0700, David Miller wrote:
> From: Eric Dumazet <edumazet@google.com>
> Date: Sat, 18 Jun 2016 16:26:40 -0700
> 
> > @@ -588,12 +594,26 @@ int ip6_err_gen_icmpv6_unreach(struct sk_buff *skb, int nhs, int type)
> >  		skb2->dev = rt->dst.dev;
> >  
> >  	ipv6_addr_set_v4mapped(ip_hdr(skb)->saddr, &temp_saddr);
> > +
> > +	if (data_len) {
> > +		/* RFC 4884 (partial) support :
> > +		 * insert 0 padding at the end, before the extensions
> > +		 */
> > +		__skb_push(skb2, nhs);
> > +		skb_reset_network_header(skb2);
> > +		memcpy(skb2->data, skb2->data + nhs, data_len - nhs);
> 
> Since this is overlapping, it really need to use memmove() instead of
> memcpy().


Interesting, I always thought memcpy(dest, src, xxx) was ok if src >
dest
