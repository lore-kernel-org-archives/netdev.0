From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next-2.6] netfilter: allow nf_tproxy_core module to
 be removed
Date: Thu, 24 Jun 2010 17:29:29 +0200
Message-ID: <4C2379D9.2080608@trash.net>
References: <20100623183503.GE2687@psychotron.bos.redhat.com>	<20100623184611.GG27132@Chamillionaire.breakpoint.cc> <20100623.115558.189705237.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, jpirko@redhat.com, netdev@vger.kernel.org,
	Balazs Scheidler <bazsi@balabit.hu>,
	KOVACS Krisztian <hidden@sch.bme.hu>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35896 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754161Ab0FXP3e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jun 2010 11:29:34 -0400
In-Reply-To: <20100623.115558.189705237.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Florian Westphal <fw@strlen.de>
> Date: Wed, 23 Jun 2010 20:46:11 +0200
>
>   
>> tproxy assigns skb->destructor, what prevents module unload while such skbs may
>> still be around?
>>     
>
> The only reference to nf_tproxy_core.ko is for the symbol, "nf_tproxy_assign_sock".
> xt_TPROXY.c, which references this symbol, thus creates a symbol dependency on this
> module, so xt_TPROXY.o needs to unload before nf_tproxy_core.ko can unload, and
> xt_TPROXY.o has it's own manner for handling module references properly.
>   

I don't see anything waiting for skbs in flight using the tproxy
destructor in either xt_TPROXY or nf_tproxy_core though, so I think
Florian is correct.

