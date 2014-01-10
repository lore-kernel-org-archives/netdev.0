From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Check skb->rxhash in gro_receive
Date: Thu, 09 Jan 2014 21:38:07 -0800
Message-ID: <1389332287.31367.88.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.02.1401092051020.25554@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:44815 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750800AbaAJFiI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 00:38:08 -0500
Received: by mail-pb0-f47.google.com with SMTP id um1so3965032pbc.6
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 21:38:08 -0800 (PST)
In-Reply-To: <alpine.DEB.2.02.1401092051020.25554@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-01-09 at 20:54 -0800, Tom Herbert wrote:
> When initializing a gro_list for a packet, first check the rxhash of
> the incoming skb against that of the skb's in the list. This should be
> a very strong inidicator of whether the flow is going to be matched,
> and potentially allows a lot of other checks to be short circuited.
> 

Hmm... this idea was discussed in the past. I used it when attempting to
use a hash table instead of a gro_list last year.

Unfortunately this added lot of cycles when rxhash is not provided by
hardware, and my tests found it was not a win.

Remember : in most cases, gro_list contains one flow, so this test does
nothing special but adds overhead.
