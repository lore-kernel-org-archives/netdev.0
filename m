From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: 2.6.25-rc: Null dereference in ip_defrag
Date: Tue, 18 Mar 2008 10:53:53 +0300
Message-ID: <47DF7511.5080502@openvz.org>
References: <20080317170008.GA30338@linuxace.com> <47DEACF7.10202@openvz.org> <47DEADC4.4010609@trash.net> <20080317194014.GA7302@linuxace.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Denis Lunev <den@openvz.org>
To: Phil Oester <kernel@linuxace.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:55159 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751081AbYCRHyB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Mar 2008 03:54:01 -0400
In-Reply-To: <20080317194014.GA7302@linuxace.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Phil Oester wrote:
> On Mon, Mar 17, 2008 at 06:43:32PM +0100, Patrick McHardy wrote:
>> Pavel Emelyanov wrote:
>>> Can you check with this patch, please (untested, but should work)?
>> This is getting pretty ugly. Shouldn't
>>
>> int ip_defrag(struct sk_buff *skb, u32 user)
>> {
>> ...
>> -         net = skb->dev->nd_net;
>> +         net = skb->dev ? skb->dev->nd_net : skb->dst->dev->nd_net;
>>
>> work as well?

It will, though I do not like such implicit decisions.

> I can try either patch, but Patrick's looks simpler and thus perhaps
> a better candidate this late in the -rc stage.
> 
> Pavel - you concur?

No one, except for a complaint, that we (me and Denis) warned other
net namespaces developers that getting a struct net from function
arguments, sockets, dst entries, devices, etc. is going to become a
pain in the ... anyway. We proposed to create current_net macro, that
would give us a correct net in any place... Such thing would allow us
to avoid this problem. But I'm afraid, that it's just too late to
change the model :(

> Phil
> 

