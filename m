From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] net: Toeplitz library functions
Date: Mon, 23 Sep 2013 22:38:38 -0700
Message-ID: <1380001118.3165.41.camel@edumazet-glaptop>
References: <alpine.DEB.2.02.1309231535030.23896@tomh.mtv.corp.google.com>
	 <1379980991.3165.37.camel@edumazet-glaptop>
	 <20130924023038.GA22393@order.stressinduktion.org>
	 <20130924033505.GB22393@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f173.google.com ([209.85.213.173]:40724 "EHLO
	mail-ye0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750706Ab3IXFim (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 01:38:42 -0400
Received: by mail-ye0-f173.google.com with SMTP id m3so1580730yen.32
        for <netdev@vger.kernel.org>; Mon, 23 Sep 2013 22:38:41 -0700 (PDT)
In-Reply-To: <20130924033505.GB22393@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-09-24 at 05:35 +0200, Hannes Frederic Sowa wrote:

> > build_ehash_secret builds up the data which seeds fragmentation ids, ephermal
> > port randomization etc. Could we drop the check of sock->type? I guess the
> > idea was that in-kernel sockets of type raw/udp do not seed the keys when no
> > entropy is available?
> 
> Would this be better (I checked inet_ehash_secret, ipv6_hash_secret
> and net_secret to actual get initialized)?
> 

inet_ehash_secret is used only to make jhash() for tcp ehash, not for
fragmentation ids or other uses (port randomization).


> [PATCH] inet: initialize hash secret values on first non-kernel socket creation
> 
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---

Why ? This looks buggy to me.
