From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: fix a race in ip4_datagram_release_cb()
Date: Tue, 08 Jul 2014 08:47:44 +0200
Message-ID: <1404802064.3515.4.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CA+FTKhs45vD66xSQRgijwFjSuy-Mt8EGr3cRv60oCcEnFPKnaQ@mail.gmail.com>
	    <1402407781.3645.426.camel@edumazet-glaptop2.roam.corp.google.com>
	    <alpine.DEB.2.02.1406101726390.11647@dtop>
	    <1402448128.3645.437.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1402449173.3645.440.camel@edumazet-glaptop2.roam.corp.google.com>
	   <1402450009.3645.444.camel@edumazet-glaptop2.roam.corp.google.com>
	   <alpine.DEB.2.02.1406281724370.18954@dtop>
	  <1404110292.15139.42.camel@edumazet-glaptop2.roam.corp.google.com>
	  <alpine.DEB.2.02.1406300112340.31629@dtop>
	 <1404117049.15139.63.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.DEB.2.02.1407071834230.586@dtop>
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
Received: from mail-wi0-f171.google.com ([209.85.212.171]:57758 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751300AbaGHGru (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 02:47:50 -0400
Received: by mail-wi0-f171.google.com with SMTP id n15so364034wiw.10
        for <netdev@vger.kernel.org>; Mon, 07 Jul 2014 23:47:49 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1407071834230.586@dtop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-07-07 at 18:41 -0700, dormando wrote:

> Mostly there, but I think we hit what might be a new bug.. The machines
> which crashed every few days previously have been stable for weeks.
> 
> however I had one machine running the new kernel in a larger cluster
> elsewhere; we had a network event and the one machine on the new kernel
> panic'ed in ipv4_dst_destroy, but what looks like a new path. Sadly I've
> had to halt the rollout :( All of the older unfixed kernels survived this
> particular network event.
> 
> Unfortunately this is still on 3.10, due to a bad softirq regression in
> 3.14 I've not had time to track down. I applied all of your patches for
> what wasn't already in 3.10. The only other change I made was to un-revert
> 62713c4b6bc10c2d082ee1540e11b01a2b2162ab - which I'd been keeping reverted
> as it was making crashes much more frequent.

Hmm, always give patch title or a valid sha1 commit, this one is not in
David trees, so its hard to tell.
