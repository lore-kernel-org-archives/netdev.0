From: Patrick McHardy <kaber@trash.net>
Subject: Re: relationship between ingress policer and netfilter hooks?
Date: Wed, 03 Jun 2009 09:18:55 +0200
Message-ID: <4A2623DF.5040800@trash.net>
References: <4A25457F.2070000@nortel.com> <4A255BAC.8070406@trash.net> <4A256E55.9090309@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Chris Friesen <cfriesen@nortel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59166 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751713AbZFCHS4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 03:18:56 -0400
In-Reply-To: <4A256E55.9090309@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Friesen wrote:
> Patrick McHardy wrote:
>> Chris Friesen wrote:
>>
>>> Hi all,
>>>
>>> Can someone tell me where the hook is for incoming packets to be sent
>>> through the ingress policer?
>>>
>>> In particular, I'm trying to find out how the ingress traffic shaping
>>> hook relates to the various netfilter hooks so that I can set them up to
>>> behave nicely together.
> 
>> They're not related at all. The ingress qdisc is hooked at
>> net/dev/core.c:handle_ing().
> 
> Thanks.  Based on that the shaping is done before any of the netfilter
> hooks, which is what I was trying to figure out.

Correct.

> On a related note...the deliver_skb() call right before the call to
> handle_ing()--is that to allow packet sockets to receive everything that
> arrives on the wire even if some of it may be dropped later?

Yes, its the final delivery for ptype_all handlers.
