From: Patrick McHardy <kaber@trash.net>
Subject: Re: 2.6.25-rc: Null dereference in ip_defrag
Date: Mon, 17 Mar 2008 18:51:57 +0100
Message-ID: <47DEAFBD.5030603@trash.net>
References: <20080317170008.GA30338@linuxace.com>	 <47DEACF7.10202@openvz.org>  <47DEADC4.4010609@trash.net> <1205776662.27115.1.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pavel Emelyanov <xemul@openvz.org>,
	Phil Oester <kernel@linuxace.com>, netdev@vger.kernel.org
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep31-int.chello.at ([62.179.121.49]:56197 "EHLO
	viefep31-int.chello.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752622AbYCQSAh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2008 14:00:37 -0400
In-Reply-To: <1205776662.27115.1.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denis V. Lunev wrote:
> On Mon, 2008-03-17 at 18:43 +0100, Patrick McHardy wrote:
>> Pavel Emelyanov wrote:
>>
>>  > Can you check with this patch, please (untested, but should work)?
>>
>> This is getting pretty ugly. Shouldn't
>>
>> int ip_defrag(struct sk_buff *skb, u32 user)
>> {
>> ...
>> -         net = skb->dev->nd_net;
>> +         net = skb->dev ? skb->dev->nd_net : skb->dst->dev->nd_net;
>>From my POW the we can just get skb->dst->dev. Could we?
> 
> I think that on IP level dealing with fragments we always have the
> destination entry. I'll recheck this tomorrow.


Unfortunately no, on the receive path connection tracking
will call ip_defrag before routing took place.
