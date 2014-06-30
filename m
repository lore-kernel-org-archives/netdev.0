From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: fix a race in ip4_datagram_release_cb()
Date: Sun, 29 Jun 2014 23:38:12 -0700
Message-ID: <1404110292.15139.42.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CA+FTKhs45vD66xSQRgijwFjSuy-Mt8EGr3cRv60oCcEnFPKnaQ@mail.gmail.com>
	  <1402407781.3645.426.camel@edumazet-glaptop2.roam.corp.google.com>
	  <alpine.DEB.2.02.1406101726390.11647@dtop>
	  <1402448128.3645.437.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1402449173.3645.440.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1402450009.3645.444.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.DEB.2.02.1406281724370.18954@dtop>
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
Received: from mail-wi0-f182.google.com ([209.85.212.182]:61845 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751964AbaF3GiS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2014 02:38:18 -0400
Received: by mail-wi0-f182.google.com with SMTP id bs8so5326584wib.9
        for <netdev@vger.kernel.org>; Sun, 29 Jun 2014 23:38:17 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1406281724370.18954@dtop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-06-28 at 17:25 -0700, dormando wrote:
> On Tue, 10 Jun 2014, Eric Dumazet wrote:
> 
> > On Tue, 2014-06-10 at 18:12 -0700, Eric Dumazet wrote:
> >
> > >
> > > For the curious, another problem is in ipv4_sk_update_pmtu()
> > >
> > > This can be called on UDP sockets, but from softirq context.
> > >
> > > We cannot use sk_dst_lock because this lock is not softirq safe.
> > >
> > > I guess we should use xchg() for sk_dst_set() and sk_dst_reset()
> >
> > This would be something like this untested patch :
> >
> 
> I see this didn't get queued for stable, should it be dropped due to the
> later patch? (which did get queued for stable).

I have this patch in my queue.

I have to submit it officially before it can be merged...

David seems quite busy these days anyway.
