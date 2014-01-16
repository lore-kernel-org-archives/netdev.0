From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v2] tcp: metrics: Avoid duplicate entries with the
 same destination-IP
Date: Thu, 16 Jan 2014 11:20:31 -0800
Message-ID: <1389900031.31367.420.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389898881-11393-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Christoph Paasch <christoph.paasch@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f177.google.com ([209.85.161.177]:46165 "EHLO
	mail-gg0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750946AbaAPTUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 14:20:35 -0500
Received: by mail-gg0-f177.google.com with SMTP id f4so1012571ggn.8
        for <netdev@vger.kernel.org>; Thu, 16 Jan 2014 11:20:34 -0800 (PST)
In-Reply-To: <1389898881-11393-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-01-16 at 20:01 +0100, Christoph Paasch wrote:
> Because the tcp-metrics is an RCU-list, it may be that two
> soft-interrupts are inside __tcp_get_metrics() for the same
> destination-IP at the same time. If this destination-IP is not yet part of
> the tcp-metrics, both soft-interrupts will end up in tcpm_new and create
> a new entry for this IP.
> So, we will have two tcp-metrics with the same destination-IP in the list.
> 
> This patch checks twice __tcp_get_metrics(). First without holding the
> lock, then while holding the lock. The second one is there to confirm
> that the entry has not been added by another soft-irq while waiting for
> the spin-lock.
> 
> Fixes: 51c5d0c4b169b (tcp: Maintain dynamic metrics in local cache.)
> Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
> ---
> 
> v2: As requested by Eric D.: Check the cache twice. Once without holding the lock,
>     and then again while holding the lock. That way we avoid taking the lock
>     needlessly.
> 
>  net/ipv4/tcp_metrics.c | 51 +++++++++++++++++++++++++++++++-------------------
>  1 file changed, 32 insertions(+), 19 deletions(-)

Reviewed-by: Eric Dumazet <edumazet@google.com>

Thanks !
