From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] af_unix: don't append consumed skbs to
 sk_receive_queue
Date: Mon, 16 Nov 2015 08:38:00 -0800
Message-ID: <1447691880.22599.68.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1447687556-22712-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34659 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751059AbbKPQiE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 11:38:04 -0500
Received: by padhx2 with SMTP id hx2so179988106pad.1
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2015 08:38:03 -0800 (PST)
In-Reply-To: <1447687556-22712-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-11-16 at 16:25 +0100, Hannes Frederic Sowa wrote:
> In case multiple writes to a unix stream socket race we could end up in a
> situation where we pre-allocate a new skb for use in unix_stream_sendpage
> but have to free it again in the locked section because another skb
> has been appended meanwhile, which we must use. Accidentally we didn't
> clear the pointer after consuming it and so we touched freed memory
> while appending it to the sk_receive_queue. So, clear the pointer after
> consuming the skb.
> 
> This bug has been found with syzkaller
> (http://github.com/google/syzkaller) by Dmitry Vyukov.
> 
> Fixes: 869e7c62486e ("net: af_unix: implement stream sendpage support")
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: Dmitry Vyukov <dvyukov@google.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
