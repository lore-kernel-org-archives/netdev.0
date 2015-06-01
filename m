From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] udp: fix behavior of wrong checksums
Date: Sun, 31 May 2015 21:42:51 -0700 (PDT)
Message-ID: <20150531.214251.957902561372382056.davem@davemloft.net>
References: <1433002613.7456.107.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemb@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45368 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751475AbbFAEmw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 00:42:52 -0400
In-Reply-To: <1433002613.7456.107.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 30 May 2015 09:16:53 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> We have two problems in UDP stack related to bogus checksums :
> 
> 1) We return -EAGAIN to application even if receive queue is not empty.
>    This breaks applications using edge trigger epoll()
> 
> 2) Under UDP flood, we can loop forever without yielding to other
>    processes, potentially hanging the host, especially on non SMP.
> 
> 
> This patch is an attempt to make things better.
> 
> We might in the future add extra support for rt applications
> wanting to better control time spent doing a recv() in a hostile
> environment. For example we could validate checksums before queuing
> packets in socket receive queue.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Yeah this looks correct, applied and queued up for -stable.

Thanks!
