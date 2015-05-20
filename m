From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 2/4] net: af_unix: implement stream sendpage support
Date: Thu, 21 May 2015 01:47:49 +0200
Message-ID: <1432165669.742118.274281209.1779FF2D@webmail.messagingengine.com>
References: <cover.1432135413.git.hannes@stressinduktion.org>
 <06647895d82d7a5188b522c00cf28398b3410628.1432135413.git.hannes@stressinduktion.org>
 <1432164094.4060.51.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:49304 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754564AbbETXru (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 19:47:50 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id C1F1020926
	for <netdev@vger.kernel.org>; Wed, 20 May 2015 19:47:49 -0400 (EDT)
In-Reply-To: <1432164094.4060.51.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 21, 2015, at 01:21, Eric Dumazet wrote:
> On Wed, 2015-05-20 at 17:35 +0200, Hannes Frederic Sowa wrote:
> > This patch implements sendpage support for AF_UNIX SOCK_STREAM
> > +
> > +	if (newskb)
> > +		skb_queue_tail(&other->sk_receive_queue, newskb);
> 
> Are you sure we need the skb_queue_tail() here (taking spinlock) ?
> 
> This would tell us there might be a possible race.
> 
> A comment would be nice eventually.

Hmm, at first sight, I think we can change this to __skb_queue_tail.
sendpage does take state_lock and readlock mutex and thus blocks out
both, recvmsg and sendmsg. unix_stream_connect is also serialized by
state_lock.

I guess I used it because of unix_stream_sendmsg, where it is actually
necessary, as recvmsg does unlink skb without state_lock and sendmsg
doesn't hold reader mutex.

Thanks for the hint!

Bye,
Hannes
