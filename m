From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net 2/2] udp: restrict offloads to one namespace
Date: Thu, 17 Dec 2015 09:49:53 +0100
Message-ID: <56727731.2010605@stressinduktion.org>
References: <1450209714-26037-1-git-send-email-hannes@stressinduktion.org>
 <1450209714-26037-2-git-send-email-hannes@stressinduktion.org>
 <20151216.190417.1337922066819496682.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com, edumazet@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:50517 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755293AbbLQIt6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 03:49:58 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 6E33420452
	for <netdev@vger.kernel.org>; Thu, 17 Dec 2015 03:49:55 -0500 (EST)
In-Reply-To: <20151216.190417.1337922066819496682.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

On 17.12.2015 01:04, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Tue, 15 Dec 2015 21:01:54 +0100
> 
>> udp tunnel offloads tend to aggregate datagrams based on inner
>> headers. gro engine gets notified by tunnel implementations about
>> possible offloads. The match is solely based on the port number.
>>
>> Imagine a tunnel bound to port 53, the offloading will look into all
>> DNS packets and tries to aggregate them based on the inner data found
>> within. This could lead to data corruption and malformed DNS packets.
>>
>> While this patch minimizes the problem and helps an administrator to find
>> the issue by querying ip tunnel/fou, a better way would be to match on
>> the specific destination ip address so if a user space socket is bound
>> to the same address it will conflict.
>>
>> Cc: Tom Herbert <tom@herbertland.com>
>> Cc: Eric Dumazet <edumazet@google.com>
>> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> 
> It looks this issue is still being hashed out so I've marked this
> patch as deferred for now.


I think we need this patch. We later can decide to add more
classification attributes, like dst ip down to gro, but the netns marks
are important.

With user namespaces a normal user can start a new network namespace
with all privileges and thus add new offloads, letting the other stack
interpret this garbage. Because the user namespace can also add
arbitrary ip addresses to its interface, solely matching those is not
enough.

Tom any further comments?

Thanks,
Hannes
