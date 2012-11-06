From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] htb: fix two bugs
Date: Mon, 05 Nov 2012 18:31:54 -0800
Message-ID: <1352169114.3140.47.camel@edumazet-glaptop>
References: <1352149561.2747.37.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Vimalkumar <j.vimal@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:34197 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933504Ab2KFCcE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2012 21:32:04 -0500
Received: by mail-pb0-f46.google.com with SMTP id rr4so30475pbb.19
        for <netdev@vger.kernel.org>; Mon, 05 Nov 2012 18:32:03 -0800 (PST)
In-Reply-To: <1352149561.2747.37.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-11-05 at 13:06 -0800, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Commit 56b765b79e9 (htb: improved accuracy at high rates)
> introduced two bugs :
> 
> 1) one bstats_update() was inadvertently removed from
>    htb_dequeue_tree(), breaking statistics/rate estimation.
> 
> 2) Missing qdisc_put_rtab() calls in htb_change_class(),
>    leaking kernel memory, now struct htb_class no longer
>    retains pointers to qdisc_rate_table structs.
> 
>    Since only rate is used, dont use qdisc_get_rtab() calls
>    copying data we ignore anyway.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Vimalkumar <j.vimal@gmail.com>
> ---

Please hold on this patch, I'll add a check in V2 :

We should make sure rates are not zero (check is done in
qdisc_get_rtab())
