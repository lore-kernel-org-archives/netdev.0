From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] af_unix: take receive queue lock while appending
 new skb
Date: Tue, 17 Nov 2015 08:29:42 -0800
Message-ID: <1447777782.22599.121.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1447769459-30452-1-git-send-email-hannes@stressinduktion.org>
	 <1447771360.22599.99.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1447772140.544921.442208625.2042D49B@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34388 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754298AbbKQQ3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 11:29:45 -0500
Received: by padhx2 with SMTP id hx2so13417738pad.1
        for <netdev@vger.kernel.org>; Tue, 17 Nov 2015 08:29:44 -0800 (PST)
In-Reply-To: <1447772140.544921.442208625.2042D49B@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-11-17 at 15:55 +0100, Hannes Frederic Sowa wrote:

> I want to move to unix_state_lock and completely drop sk_buff_head.lock
> in af_unix, as such I would prefer to keep it this way as in some other
> places in af_unix.c (e.g. unix_stream_connect).
> 
> Or do you have a strong opinion on that?


I am saying we use 2 times skb_queue_tail(), one time skb_unlink(),
and 2 times skb_queue_purge(), all using spin_lock_irqsave()

But you took the single __skb_queue_tail() that was present in this
file ;)

No strong opinion, just a matter of simplicity and code size.

Reported-by: Eric Dumazet <edumazet@google.com>
Acked-by: Eric Dumazet <edumazet@google.com>
