From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: LOCKDEP complaints in l2tp_xmit_skb()
Date: Thu, 28 Jun 2012 10:57:42 +0200
Message-ID: <1340873862.13187.5.camel@edumazet-glaptop>
References: <20120627111152.GA2531@raven>
	 <1340866572.26242.312.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Tom Parkin <tparkin@katalix.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:44692 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753223Ab2F1I5t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 04:57:49 -0400
Received: by eeit10 with SMTP id t10so662771eei.19
        for <netdev@vger.kernel.org>; Thu, 28 Jun 2012 01:57:48 -0700 (PDT)
In-Reply-To: <1340866572.26242.312.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-06-28 at 08:56 +0200, Eric Dumazet wrote:

> [PATCH] net: Qdisc busylock gets its own lockdep class
> 
> Tom Parkin reported following LOCKDEP splat :
..
> 
> Instruct lockdep that each Qdisc busylock is independant, or else
> bonding or various tunnels can trigger a splat.
> 
> Reported-by: Tom Parkin <tparkin@katalix.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---

I reproduced the bug using a bond0 device, adding a qdisc on it,
(one Qdisc on bond0, and a Qdisc on the slave too)

Problem with this patch is I have following message :

BUG: key ffff88..... not in .data!

No more LOCKDEP splat, but patch not good as is.
