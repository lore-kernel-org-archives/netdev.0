From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC net] tcp: metrics: Avoid duplicate entries with the same
 destination-IP
Date: Mon, 13 Jan 2014 08:47:49 -0800
Message-ID: <1389631669.31367.221.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389626736-3143-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Christoph Paasch <christoph.paasch@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:61602 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754283AbaAMQrv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 11:47:51 -0500
Received: by mail-pa0-f44.google.com with SMTP id kq14so1307286pab.31
        for <netdev@vger.kernel.org>; Mon, 13 Jan 2014 08:47:51 -0800 (PST)
In-Reply-To: <1389626736-3143-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-01-13 at 16:25 +0100, Christoph Paasch wrote:

> Another solution might be to leave tcp_get_metrics() as it is, and in
> tcpm_new do another call to __tcp_get_metrics() while holding the
> spin-lock. We would then check __tcp_get_metrics twice for new entries
> but we won't hold the spin-lock needlessly anymore.

This is the only solution if you want to fix this.
Cost of lookup are the cache line misses.
Avoiding the spinlock is a must.

The second 'lookup' is basically free, as the first one have populated
cpu caches.
