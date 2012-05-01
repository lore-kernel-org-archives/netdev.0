From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: add a prefetch in socket backlog
 processing
Date: Tue, 01 May 2012 08:42:31 +0200
Message-ID: <1335854551.11396.28.camel@edumazet-glaptop>
References: <1335838029.11396.12.camel@edumazet-glaptop>
	 <1335842663.26217.10.camel@joe2Laptop>
	 <1335854091.11396.21.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:40435 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751246Ab2EAGmg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2012 02:42:36 -0400
Received: by wgbdr13 with SMTP id dr13so1211696wgb.1
        for <netdev@vger.kernel.org>; Mon, 30 Apr 2012 23:42:35 -0700 (PDT)
In-Reply-To: <1335854091.11396.21.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-05-01 at 08:34 +0200, Eric Dumazet wrote:

> Basically this patch avoids one memory cache miss per iteration.
> 

This patch was the easy part.

I am now working on refining __skb_dequeue() API to avoid the cache line
miss when we perform the __skb_unlink() and allow a prefetch(next) as
well, to speedup process_backlog().
