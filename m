From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC net-next 11/22] dst: Metadata destinations
Date: Fri, 10 Jul 2015 21:19:50 +0200
Message-ID: <20150710191950.GA15042@pox.localdomain>
References: <cover.1436537414.git.tgraf@suug.ch>
 <1b20319e1ff0f2be28e783b90ac48738d6a8b72b.1436537414.git.tgraf@suug.ch>
 <alpine.LFD.2.11.1507102139530.1754@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: roopa@cumulusnetworks.com, rshearma@brocade.com,
	ebiederm@xmission.com, hannes@stressinduktion.org,
	pshelar@nicira.com, jesse@nicira.com, davem@davemloft.net,
	daniel@iogearbox.net, tom@herbertland.com, edumazet@google.com,
	jiri@resnulli.us, marcelo.leitner@gmail.com,
	stephen@networkplumber.org, jpettit@nicira.com, kaber@trash.net,
	netdev@vger.kernel.org, dev@openvswitch.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:35903 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932536AbbGJTTy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 15:19:54 -0400
Received: by widjy10 with SMTP id jy10so23225702wid.1
        for <netdev@vger.kernel.org>; Fri, 10 Jul 2015 12:19:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1507102139530.1754@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/10/15 at 09:57pm, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Fri, 10 Jul 2015, Thomas Graf wrote:
> 
> > --- a/net/ipv4/route.c
> > +++ b/net/ipv4/route.c
> > @@ -1691,6 +1691,8 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
> >  	   by fib_lookup.
> >  	 */
> >  
> > +	skb_dst_drop(skb);
> > +
> 
> 	This is not very safe. There are places that
> call ip_route_input() for temporary lookups and they
> do not set NULL. For example, icmp_route_lookup(),
> may be there are other such places...

Wow. What a tremendous hack ;-) It saves and restores the original
dst ref to avoid the leaked reference.

> 	OTOH, ip_options_rcv_srr() looks correct to use
> skb_dst_set(skb, NULL), may be such call should be
> added if it is missing...

Agreed. This seems to be the right fix. I'll apply to this
icmp_route_lookup() as well.

Thanks!
