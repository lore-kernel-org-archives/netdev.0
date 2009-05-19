From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: gen_estimator: use 64 bits intermediate
	counters for bps
Date: Tue, 19 May 2009 07:02:52 +0000
Message-ID: <20090519070252.GA4210@ff.dom.local>
References: <20090516141430.GB3013@ami.dom.local> <4A118F98.60101@cosmosbay.com> <20090518172349.GA2755@ami.dom.local> <20090518.145233.212710505.davem@davemloft.net> <4A11F67B.3050805@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, vexwek@gmail.com,
	netdev@vger.kernel.org, kaber@trash.net, devik@cdi.cz
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f174.google.com ([209.85.218.174]:50505 "EHLO
	mail-bw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752497AbZESHC4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 03:02:56 -0400
Received: by bwz22 with SMTP id 22so3627500bwz.37
        for <netdev@vger.kernel.org>; Tue, 19 May 2009 00:02:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A11F67B.3050805@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 19, 2009 at 01:59:55AM +0200, Eric Dumazet wrote:
...
> diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
...
> -		e->avbps += ((long)rate - (long)e->avbps) >> e->ewma_log;
> +		e->avbps += ((s64)(brate - e->avbps)) >> e->ewma_log;

Btw., I'm a bit concerned about the syntax here: isn't such shifting
of signed ints implementation dependant?

Jarek P.
