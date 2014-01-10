From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Check skb->rxhash in gro_receive
Date: Thu, 09 Jan 2014 21:43:55 -0800
Message-ID: <1389332635.31367.91.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.02.1401092051020.25554@tomh.mtv.corp.google.com>
	 <1389332287.31367.88.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:62905 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750793AbaAJFn6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 00:43:58 -0500
Received: by mail-pd0-f169.google.com with SMTP id v10so4154328pde.0
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 21:43:58 -0800 (PST)
In-Reply-To: <1389332287.31367.88.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-01-09 at 21:38 -0800, Eric Dumazet wrote:

> Hmm... this idea was discussed in the past. I used it when attempting to
> use a hash table instead of a gro_list last year.
> 
> Unfortunately this added lot of cycles when rxhash is not provided by
> hardware, and my tests found it was not a win.
> 
> Remember : in most cases, gro_list contains one flow, so this test does
> nothing special but adds overhead.

Additional point : For napi_gro_frag() users, skb->head do not contains
headers, so flow dissector enters slow path to fetch the headers from
the fragment, one by one.
