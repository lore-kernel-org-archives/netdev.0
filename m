From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: PIM-SM namespace changes
Date: Mon, 15 Jun 2009 19:58:40 +0400
Message-ID: <4A366FB0.40608@openvz.org>
References: <20090518.222429.135907168.davem@davemloft.net>	<20090520004344.GA10143@boeing.com> <20090614.031716.53296931.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: thomas.goff@boeing.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:1347 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763319AbZFOP7F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jun 2009 11:59:05 -0400
In-Reply-To: <20090614.031716.53296931.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Tom Goff <thomas.goff@boeing.com>
> Date: Tue, 19 May 2009 17:43:44 -0700
> 
>> For protocol registration I see three basic approaches for using PIM
>> with namespaces:
>>
>>   - unconditionally add PIM when multicast routing is initialized
>>     (maybe only ifdef CONFIG_NET_NS, otherwise preserve the current
>>     behavior)
>>
>>   - keep a count of the number of namespaces that have enabled PIM and
>>     add/delete PIM when transitioning from/to zero
>>
>>   - make all or some protocol registration per network namespace
>>
>> There are obviously tradeoffs and I would appreciate any
>> comments/suggestions on alternatives that allow namespace use of
>> dynamically enabled protocols.
> 
> Ok, I'm willing to accept your current approach for now, let's
> see what falls out of this.  Patch applied, thanks.
> 
> Doing the enabling per-namespace is complexity for an unknown
> gain.  I don't even know what the benefit could be for how we
> behaved previously.
> 
> Anyone know?

Well, maybe I do :)

I haven't thought much about per-namespace protocols, but I think, that
it makes sense to enable/disable at least virtual devices (tunnels and
vlans currently) per-namespace.

Not every namespace really needs this big amount of functionality and
saving sizeof(struct net_device) + private - the fallback devices each
tunnel creates, and this is somewhat around 4Kb each - sounds good.

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

