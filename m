From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/5] net: mvneta: use per_cpu stats to fix an SMP lock up
Date: Sun, 12 Jan 2014 10:07:36 -0800
Message-ID: <1389550056.31367.186.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389519069-1619-1-git-send-email-w@1wt.eu>
	 <1389519069-1619-3-git-send-email-w@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:41257 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750956AbaALSHi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jan 2014 13:07:38 -0500
Received: by mail-pd0-f176.google.com with SMTP id r10so2547063pdi.35
        for <netdev@vger.kernel.org>; Sun, 12 Jan 2014 10:07:37 -0800 (PST)
In-Reply-To: <1389519069-1619-3-git-send-email-w@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-01-12 at 10:31 +0100, Willy Tarreau wrote:
> Stats writers are mvneta_rx() and mvneta_tx(). They don't lock anything
> when they update the stats, and as a result, it randomly happens that
> the stats freeze on SMP if two updates happen during stats retrieval.

Your patch is OK, but I dont understand how this freeze can happen.

TX and RX uses a separate syncp, and TX is protected by a lock, RX
is protected by NAPI bit.

Stats retrieval uses the appropriate BH disable before the fetches...


> This is very easily reproducible by starting two HTTP servers and binding
> each of them to a different CPU, then consulting /proc/net/dev in loops
> during transfers, the interface should immediately lock up. This issue
> also randomly happens upon link state changes during transfers, because
> the stats are collected in this situation, but it takes more attempts to
> reproduce it.
