From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] tcp: use order-3 pages in tcp_sendmsg()
Date: Thu, 15 Nov 2012 05:47:26 -0800
Message-ID: <1352987246.4497.36.camel@edumazet-glaptop>
References: <1347868144.26523.71.camel@edumazet-glaptop>
	 <CAAM7YAm+XJKTxJStLMoo4RRV85oogN5wCHfXorkEiUHKqNKHDQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "Yan, Zheng" <yanzheng@21cn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:63414 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1767793Ab2KONrc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 08:47:32 -0500
Received: by mail-ia0-f174.google.com with SMTP id y25so1000517iay.19
        for <netdev@vger.kernel.org>; Thu, 15 Nov 2012 05:47:30 -0800 (PST)
In-Reply-To: <CAAM7YAm+XJKTxJStLMoo4RRV85oogN5wCHfXorkEiUHKqNKHDQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-11-15 at 15:52 +0800, Yan, Zheng wrote:
> LLC misses happen on the receiver size. It means most pages allocated by the
> senders are cache hot. But when using order-3 pages, 2048 * 32k = 64M, 64M
> is much larger than LLC size.

By the way, this 2048*32k is wrong, as the receiver only uses fragments
in pages, and its not related to the "tcp: use order-3 pages in
tcp_sendmsg()" commit

Many drivers use order-0 pages to hold ethernet frames, regardless of
what was used by the sender ;)
