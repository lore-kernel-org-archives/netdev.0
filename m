From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Patch 4/5] Network Drop Monitor: Adding drop monitor implementation
 & Netlink protocol
Date: Wed, 10 Jun 2009 12:35:08 +0200
Message-ID: <4A2F8C5C.5050108@trash.net>
References: <20090402153042.GB1670@gondor.apana.org.au>	<20090405.025920.75648090.davem@davemloft.net>	<49DA01E9.6010602@trash.net> <20090610.010828.81117955.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, nhorman@tuxdriver.com,
	zbr@ioremap.net, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54508 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752956AbZFJKfJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 06:35:09 -0400
In-Reply-To: <20090610.010828.81117955.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Mon, 06 Apr 2009 15:21:45 +0200
> 
>> I'd also suggest to get rid of the 64k attribute and message size
>> limit at the same time, this is making it quite hard to support
>> transactional semantics for large updates (f.i. for nf_tables sets).
> 
> Another option is to support continuations of some sort.

Yes, something like NLM_F_MULTI to accumulate multiple messages might
help. I'm not sure yet whether this can be used to make the entire
operation atomic since the individual attributes still can't span more
than one skb, but it looks worth a try.
