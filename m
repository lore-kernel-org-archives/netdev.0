From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] tcp: avoid tx starvation by SYNACK packets
Date: Tue, 26 Jun 2012 06:51:36 +0200
Message-ID: <1340686296.10893.115.camel@edumazet-glaptop>
References: <1338615992.2760.1665.camel@edumazet-glaptop>
	 <CAGK4HS8Hae_4sNQeGXGc4ocK1-2DVtCUdBAPj7+DY_iF6-2zOA@mail.gmail.com>
	 <1340440962.17495.39.camel@edumazet-glaptop>
	 <20120625.154340.158890441165257041.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: subramanian.vijay@gmail.com, dave.taht@gmail.com,
	hans.schillstrom@ericsson.com, netdev@vger.kernel.org,
	ncardwell@google.com, therbert@google.com, brouer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:54750 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751416Ab2FZEvm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 00:51:42 -0400
Received: by weyu7 with SMTP id u7so3287894wey.19
        for <netdev@vger.kernel.org>; Mon, 25 Jun 2012 21:51:40 -0700 (PDT)
In-Reply-To: <20120625.154340.158890441165257041.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-06-25 at 15:43 -0700, David Miller wrote:

> I don't agree with this change.
> 
> What is the point in having real classification configuration if
> arbitrary places in the network stack are going to override SKB
> priority with a fixed priority setting?
> 
> I bet the person who set listening socket priority really meant it and
> does not expect you to override it.


If I add a test on listener_sk->sk_priority being 0, would you accept
the patch ? If classification is done after tcp stack, it wont be hurt
by initial skb priority ?

instead of :

	/* SYNACK sent in SYNCOOKIE mode have low priority */
	skb->priority = nocache ? TC_PRIO_FILLER : sk->sk_priority;

Having :

	/* SYNACK sent in SYNCOOKIE mode have low priority */
	skb->priority = (nocache && !sk->sk_priority) ?
			TC_PRIO_FILLER : sk->sk_priority;
