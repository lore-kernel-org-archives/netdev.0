From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/5] net: mvneta: use per_cpu stats to fix an SMP lock up
Date: Sun, 12 Jan 2014 16:45:03 -0800
Message-ID: <1389573903.31367.190.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389519069-1619-1-git-send-email-w@1wt.eu>
	 <1389519069-1619-3-git-send-email-w@1wt.eu>
	 <1389550056.31367.186.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140112220921.GE16576@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:50268 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899AbaAMApF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jan 2014 19:45:05 -0500
Received: by mail-pd0-f173.google.com with SMTP id p10so6722932pdj.18
        for <netdev@vger.kernel.org>; Sun, 12 Jan 2014 16:45:05 -0800 (PST)
In-Reply-To: <20140112220921.GE16576@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-01-12 at 23:09 +0100, Willy Tarreau wrote:

> But we can have multiple tx in parallel, one per queue. And it's only
> when I explicitly bind two servers to two distinct CPU cores that I
> can trigger the issue, which seems to confirm that this is the cause
> of the issue.

So this driver has multiqueue ?

Definitely it should have one syncp per queue.

Or per cpu stats, as your patch did.

Thanks !
