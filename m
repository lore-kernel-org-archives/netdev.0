From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] af_unix: take receive queue lock while appending new skb
Date: Tue, 17 Nov 2015 15:55:40 +0100
Message-ID: <1447772140.544921.442208625.2042D49B@webmail.messagingengine.com>
References: <1447769459-30452-1-git-send-email-hannes@stressinduktion.org>
 <1447771360.22599.99.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:39268 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751903AbbKQOzl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 09:55:41 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 86BC82087D
	for <netdev@vger.kernel.org>; Tue, 17 Nov 2015 09:55:40 -0500 (EST)
In-Reply-To: <1447771360.22599.99.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Tue, Nov 17, 2015, at 15:42, Eric Dumazet wrote:
> On Tue, 2015-11-17 at 15:10 +0100, Hannes Frederic Sowa wrote:
> > While possibly in future we don't necessarily need to use
> > sk_buff_head.lock this is a rather larger change, as it affects the
> > af_unix fd garbage collector, diag and socket cleanups. This is too much
> > for a stable patch.
> > 
> > For the time being grab sk_buff_head.lock without disabling bh and irqs,
> > so don't use locked skb_queue_tail.
> 
> I would use skb_queue_tail() as we already use it in two different
> places in af_unix.c, like unix_stream_sendmsg()
> 
> It is hardly a fast path anyway, so lets keep code short.
> 
> Then, in net-next, if you really want, add a new skb_queue_tail_lock()
> or similar helper ?

I want to move to unix_state_lock and completely drop sk_buff_head.lock
in af_unix, as such I would prefer to keep it this way as in some other
places in af_unix.c (e.g. unix_stream_connect).

Or do you have a strong opinion on that?

Thanks,
Hannes
