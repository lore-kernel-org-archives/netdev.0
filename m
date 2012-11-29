From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH V2 3/9] net: frag, move LRU list maintenance
 outside of rwlock
Date: Thu, 29 Nov 2012 10:33:13 -0800
Message-ID: <1354213993.3299.23.camel@edumazet-glaptop>
References: <1354211659.3299.15.camel@edumazet-glaptop>
	 <20121129.130506.329791401604974668.davem@davemloft.net>
	 <1354213492.3299.22.camel@edumazet-glaptop>
	 <20121129.133108.427624036846294750.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, fw@strlen.de, netdev@vger.kernel.org,
	pablo@netfilter.org, tgraf@suug.ch, amwang@redhat.com,
	kaber@trash.net, paulmck@linux.vnet.ibm.com,
	herbert@gondor.hengli.com.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:57706 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754497Ab2K2SdP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 13:33:15 -0500
Received: by mail-pb0-f46.google.com with SMTP id wy7so10746184pbc.19
        for <netdev@vger.kernel.org>; Thu, 29 Nov 2012 10:33:15 -0800 (PST)
In-Reply-To: <20121129.133108.427624036846294750.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-11-29 at 13:31 -0500, David Miller wrote:

> I think a per-cpu hash might make more sense.
> 
> This would scale our limits to the size of the system.
> 
> I'm willing to be convinced otherwise, but it seems the most
> sensible thing to do.

It would break in many cases, when frags are spreaded on different cpus.
