From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v4 1/3] flow_dissector: factor out the ports
 extraction in skb_flow_get_ports
Date: Thu, 26 Sep 2013 09:33:22 -0700
Message-ID: <1380213202.3165.195.camel@edumazet-glaptop>
References: <1380212024-3417-1-git-send-email-nikolay@redhat.com>
	 <1380212024-3417-2-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, andy@greyhouse.net,
	fubar@us.ibm.com, vfalico@redhat.com
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35652 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752074Ab3IZQdY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Sep 2013 12:33:24 -0400
Received: by mail-pa0-f50.google.com with SMTP id fb1so1522673pad.23
        for <netdev@vger.kernel.org>; Thu, 26 Sep 2013 09:33:24 -0700 (PDT)
In-Reply-To: <1380212024-3417-2-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-09-26 at 18:13 +0200, Nikolay Aleksandrov wrote:

>  	flow->ip_proto = ip_proto;
> -	poff = proto_ports_offset(ip_proto);
> -	if (poff >= 0) {
> -		__be32 *ports, _ports;
> -
> -		nhoff += poff;
> -		ports = skb_header_pointer(skb, nhoff, sizeof(_ports), &_ports);
> -		if (ports)
> -			flow->ports = *ports;
> -	}
> -
> +	flow->ports = skb_flow_get_ports(skb, nhoff, ip_proto);
>  	flow->thoff = (u16) nhoff;
>  
>  	return true;



The best way is to ask David to apply my fix in net tree, then your
patch will be on top of it.

Mixing a fix and a factoring seems not right.
