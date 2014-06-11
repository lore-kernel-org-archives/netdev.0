From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: fix a race in ip4_datagram_release_cb()
Date: Tue, 10 Jun 2014 17:55:28 -0700
Message-ID: <1402448128.3645.437.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CA+FTKhs45vD66xSQRgijwFjSuy-Mt8EGr3cRv60oCcEnFPKnaQ@mail.gmail.com>
	 <1402407781.3645.426.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.DEB.2.02.1406101726390.11647@dtop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexey Preobrazhensky <preobr@google.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	David Miller <davem@davemloft.net>, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Lars Bull <larsbull@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Bruce Curtis <brutus@google.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: dormando <dormando@rydia.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:55339 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751633AbaFKAzd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2014 20:55:33 -0400
Received: by mail-pa0-f53.google.com with SMTP id kx10so1256005pab.26
        for <netdev@vger.kernel.org>; Tue, 10 Jun 2014 17:55:33 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1406101726390.11647@dtop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-06-10 at 17:32 -0700, dormando wrote:

> >
> 
> This is neat. So just confirming that I understand (thanks for re-cc'ing
> me btw <3):
> 
> Because of the UDP glitch, it can cause either the kernel panic in the UDP
> code, but also elsewhere in the TCP stack based on if it's fiddling with
> the same DST being hosed by a UDP packet?
> 
> Unfortunately we're observing a pretty severe sintr cpu increase under
> 3.14, so I'm going to try this on 3.10.latest. Any potential issues there?
> 
> Thankfully it seems like our udpkill utility will reproduce it quickly.
> Lets see how it goes!

This is a start, because we have other bugs of the same kind.

I was working on follow up
