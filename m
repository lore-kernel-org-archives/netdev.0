From: KOVACS Krisztian <hidden@sch.bme.hu>
Subject: Re: [PATCH net-next-2.6] netfilter: allow nf_tproxy_core module to be
 removed
Date: Fri, 25 Jun 2010 09:56:57 +0200
Message-ID: <4C246149.3090603@sch.bme.hu>
References: <20100623183503.GE2687@psychotron.bos.redhat.com>
 <20100623184611.GG27132@Chamillionaire.breakpoint.cc>
 <20100623.115558.189705237.davem@davemloft.net> <4C2379D9.2080608@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: David Miller <davem@davemloft.net>, fw@strlen.de,
	jpirko@redhat.com, netdev@vger.kernel.org,
	Balazs Scheidler <bazsi@balabit.hu>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from balu.sch.bme.hu ([152.66.208.40]:47576 "EHLO balu.sch.bme.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751558Ab0FYI5G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jun 2010 04:57:06 -0400
Received: from [IPv6:::1] ([152.66.208.86])
 by balu.sch.bme.hu (Sun Java System Messaging Server 6.2-7.05 (built Sep  5
 2006)) with ESMTPSA id <0L4K00EKF8QXQDC0@balu.sch.bme.hu> for
 netdev@vger.kernel.org; Fri, 25 Jun 2010 09:57:01 +0200 (CEST)
In-reply-to: <4C2379D9.2080608@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 06/24/2010 05:29 PM, Patrick McHardy wrote:
> David Miller wrote:
>> From: Florian Westphal <fw@strlen.de>
>> Date: Wed, 23 Jun 2010 20:46:11 +0200
>>
>>> tproxy assigns skb->destructor, what prevents module unload while
>>> such skbs may
>>> still be around?
>>
>> The only reference to nf_tproxy_core.ko is for the symbol,
>> "nf_tproxy_assign_sock".
>> xt_TPROXY.c, which references this symbol, thus creates a symbol
>> dependency on this
>> module, so xt_TPROXY.o needs to unload before nf_tproxy_core.ko can
>> unload, and
>> xt_TPROXY.o has it's own manner for handling module references properly.
>
> I don't see anything waiting for skbs in flight using the tproxy
> destructor in either xt_TPROXY or nf_tproxy_core though, so I think
> Florian is correct.

Yes, I think Florian and Patrick's right. Right now there's nothing 
preventing xt_TPROXY and nf_tproxy_core from being removed while there 
are skbs in flight with the tproxy destructor set.

-- 
KOVACS Krisztian
