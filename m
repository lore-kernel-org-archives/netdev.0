From: Patrick McHardy <kaber@trash.net>
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked version
 of Tomasz's patch set
Date: Wed, 23 Apr 2008 02:03:43 +0200
Message-ID: <480E7CDF.2060301@trash.net>
References: <200804211817.01189.tomasz@grobelny.oswiecenia.net>	<480D6FFA.80205@trash.net>	<200804222245.53322.tomasz@grobelny.oswiecenia.net> <20080422.150648.158484938.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tomasz@grobelny.oswiecenia.net, acme@redhat.com,
	gerrit@erg.abdn.ac.uk, dccp@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51879 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761293AbYDWADm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2008 20:03:42 -0400
In-Reply-To: <20080422.150648.158484938.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
> Date: Tue, 22 Apr 2008 22:45:53 +0200
> 
>> Maybe I wasn't clear enough with my question. I understand that
>> these two memsets would have to be readded. But my question is: did
>> you identify any bugs that were caused by junk in skb->cb before
>> applying your patch? If so, do you have any test cases? It could
>> help to check code for correctness if one day more space in skb->cb
>> will be needed (which of course doesn't have to be in the nearest
>> future).
> 
> I think Patrick noticed it because it broke netfilter.
> 

Exactly, at least one path to the IP stack didn't clear
the CB (I don't recall the exact function, sorry). The
same is true for IPv6.

The testcase was transfering data over NATed DCCP connections,
some packets had garbage in IPCB(skb)->flags, which caused
IP to skip the POST_ROUTING hook, breaking NAT and conntrack.

