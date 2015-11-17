From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] af_unix: take receive queue lock while appending
 new skb
Date: Tue, 17 Nov 2015 06:42:40 -0800
Message-ID: <1447771360.22599.99.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1447769459-30452-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33611 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750708AbbKQOmm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 09:42:42 -0500
Received: by pabfh17 with SMTP id fh17so11429128pab.0
        for <netdev@vger.kernel.org>; Tue, 17 Nov 2015 06:42:42 -0800 (PST)
In-Reply-To: <1447769459-30452-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-11-17 at 15:10 +0100, Hannes Frederic Sowa wrote:
> While possibly in future we don't necessarily need to use
> sk_buff_head.lock this is a rather larger change, as it affects the
> af_unix fd garbage collector, diag and socket cleanups. This is too much
> for a stable patch.
> 
> For the time being grab sk_buff_head.lock without disabling bh and irqs,
> so don't use locked skb_queue_tail.

I would use skb_queue_tail() as we already use it in two different
places in af_unix.c, like unix_stream_sendmsg()

It is hardly a fast path anyway, so lets keep code short.

Then, in net-next, if you really want, add a new skb_queue_tail_lock()
or similar helper ?
