From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Stochastic Fair Blue queue discipline
Date: Tue, 08 Apr 2008 14:11:27 +0200
Message-ID: <47FB60EF.1080004@trash.net>
References: <87skxxb8br.fsf@pirx.pps.jussieu.fr> <873apwrc4t.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Juliusz Chroboczek <jch@pps.jussieu.fr>, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36672 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751068AbYDHMLc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2008 08:11:32 -0400
In-Reply-To: <873apwrc4t.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen wrote:
> Juliusz Chroboczek <jch@pps.jussieu.fr> writes:
> 
> 
> Have not read everything. General comment you'll likely need to 
> do some code style cleanups (read Documentation/CodingStyle) 
> Especially indentation should be consistent (one easy way 
> to get that would be to run it through Lindent, although you
> might need to review it afterwards because Lindent sometimes does
> weird things)
> 
>> +
>> +static unsigned sfb_hash(struct sk_buff *skb, int hash, int filter,
>> +                         struct sfb_sched_data *q)
>> +{
>> +	u32 h, h2;
>> +        u8 hash_type = q->hash_type;
>> +
>> +	switch (skb->protocol) {
>> +	case __constant_htons(ETH_P_IP):
> 
> I think we have multiple qdiscs now doing very similar such hashes.
> Any chance this could be factored out into a common library function 
> first?

I'd suggest to use the flow classifier for this. For simplicity
you could attach a default classifier that uses the same keys as
this one.

