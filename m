From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net 4/4] tcp: various missing rcu_read_lock around
 __sk_dst_get
Date: Fri, 1 Apr 2016 02:01:50 +0200
Message-ID: <56FDBA6E.5030508@stressinduktion.org>
References: <1459466982-20432-1-git-send-email-hannes@stressinduktion.org>
 <1459466982-20432-5-git-send-email-hannes@stressinduktion.org>
 <1459467595.6473.233.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	sasha.levin@oracle.com, daniel@iogearbox.net,
	alexei.starovoitov@gmail.com, mkubecek@suse.cz
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:54198 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752573AbcDAABz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 20:01:55 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 6670E20C6A
	for <netdev@vger.kernel.org>; Thu, 31 Mar 2016 20:01:54 -0400 (EDT)
In-Reply-To: <1459467595.6473.233.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On 01.04.2016 01:39, Eric Dumazet wrote:
> On Fri, 2016-04-01 at 01:29 +0200, Hannes Frederic Sowa wrote:
>> Various fixes which were discovered by this changeset. More probably
>> to come...
>
>
> Really ?
>
> Again, TCP stack locks the socket most of the time.
>
> The fact that lockdep does not understand this is not a reason to add
> this overhead.

I don't see how lockdep does not understand this? I think I added the 
appropriate helper to exactly verify if we have the socket lock with 
lockdep, please have a look at lockdep_sock_is_held in patch #2.

Some of the patches also just reorder the rcu_read_lock, which is anyway 
mostly free.

Bye,
Hannes
