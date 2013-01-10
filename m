From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: splice: fix an infinite loop in tcp_read_sock()
Date: Thu, 10 Jan 2013 15:05:55 -0800
Message-ID: <1357859155.27446.2768.camel@edumazet-glaptop>
References: <1357837570.27446.2285.camel@edumazet-glaptop>
	 <20130110230145.GC17390@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:40135 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753513Ab3AJXF6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 18:05:58 -0500
Received: by mail-pa0-f43.google.com with SMTP id fb10so632686pad.2
        for <netdev@vger.kernel.org>; Thu, 10 Jan 2013 15:05:57 -0800 (PST)
In-Reply-To: <20130110230145.GC17390@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-01-11 at 00:01 +0100, Willy Tarreau wrote:
> Hi Eric,

> Thanks for catching this one. I'm amazed we didn't notice it earlier,
> I've been running my stress-test kernels with this patch applied since
> we did it.
> 

Thats because you splice(    very_large_amount_of_bytes), so you dont
hit this bug.

netperf does the splice (    exact_amount_of_bytes ) so hits this pretty
fast on loopback at least.

Thanks !
