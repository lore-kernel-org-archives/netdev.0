From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC net-next 2/2] udp: No longer use SLAB_DESTROY_BY_RCU
Date: Mon, 28 Mar 2016 13:01:33 -0700
Message-ID: <1459195293.6473.118.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1458944964-12890-1-git-send-email-edumazet@google.com>
	 <1458944964-12890-3-git-send-email-edumazet@google.com>
	 <56F95884.8010901@hpe.com>
	 <1459184434.6473.104.camel@edumazet-glaptop3.roam.corp.google.com>
	 <56F97B70.1000904@hpe.com>
	 <1459191346.6473.111.camel@edumazet-glaptop3.roam.corp.google.com>
	 <56F981D7.2050801@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>
To: Rick Jones <rick.jones2@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:36004 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755094AbcC1UBg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2016 16:01:36 -0400
Received: by mail-pa0-f47.google.com with SMTP id tt10so105765544pab.3
        for <netdev@vger.kernel.org>; Mon, 28 Mar 2016 13:01:36 -0700 (PDT)
In-Reply-To: <56F981D7.2050801@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-03-28 at 12:11 -0700, Rick Jones wrote:

> I was under the impression that individual DNS queries were supposed to 
> have not only random DNS query IDs but also originate from random UDP 
> source ports.  https://tools.ietf.org/html/rfc5452 4.5 at least touches 
> on the topic but I don't see it making it hard and fast.  By section 10 
> though it is more explicit:
> 
>     This document recommends the use of UDP source port number
>     randomization to extend the effective DNS transaction ID beyond the
>     available 16 bits.
> 
> That being the case, if indeed there were to be 30000-odd concurrent 
> requests outstanding "upstream" from that location there'd have to be 
> 30000 ephemeral ports in play.

Sure, so these heavy duty programs have to consider the randomness
implications already, when picking a port in their pool.

Using the kernel and force socket()/bind()/close() in the hope to get
random values is safe, but never had been optimal for performance.

Note : file structures got RCU freeing back in 2.6.14, and I do not
think named users ever complained about added cost ;)
