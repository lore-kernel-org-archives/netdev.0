From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] GRO scalability
Date: Mon, 08 Oct 2012 20:28:57 +0200
Message-ID: <1349720937.21172.3573.camel@edumazet-glaptop>
References: <1348750130.5093.1227.camel@edumazet-glaptop>
	 <CAEP_g=-JAYHXM86AYNp7BhDV+eqfkKVgC+SJS1MVdo0K8fRLSQ@mail.gmail.com>
	 <1348769294.5093.1566.camel@edumazet-glaptop>
	 <1348769990.5093.1584.camel@edumazet-glaptop>
	 <CAEP_g=8B7xZPxye0Kuu-EVKpTDt1a3nsJKb61aaYaqOGsYGx8w@mail.gmail.com>
	 <1348841041.5093.2477.camel@edumazet-glaptop>
	 <CAEP_g=_nSb-ite51PM-E8SY53yOPiZs8N3gDrYNc0L4OU2Ht=A@mail.gmail.com>
	 <1349448747.21172.113.camel@edumazet-glaptop>  <506F23F6.1060704@hp.com>
	 <1349463634.21172.152.camel@edumazet-glaptop>  <506F368F.3070403@hp.com>
	 <1349467578.21172.178.camel@edumazet-glaptop>  <50730217.6020206@hp.com>
	 <1349715561.21172.3463.camel@edumazet-glaptop>  <5073121B.2070300@hp.com>
	 <1349718955.21172.3534.camel@edumazet-glaptop>  <5073199F.6040408@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Jesse Gross <jesse@nicira.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:33916 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752582Ab2JHS3D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2012 14:29:03 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so2217965bkc.19
        for <netdev@vger.kernel.org>; Mon, 08 Oct 2012 11:29:01 -0700 (PDT)
In-Reply-To: <5073199F.6040408@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-10-08 at 11:21 -0700, Rick Jones wrote:

> Did I then mis-interpret:
> 
> > 2) Use a LRU list to eventually be able to 'flush' too old packets,
> >    even if the napi never completes. Each time we process a new packet,
> >    being a GRO candidate or not, we increment a napi->sequence, and we
> >    flush the oldest packet in gro_lru_list if its own sequence is too
> >    old.
> 
> in your initial RFC email?  Because I took that as flushing a given 
> packet if N packets have come through since that packet was queued to 
> await coalescing.

Yes, this was refined in the patch I sent.

Currently using jiffies, but my plan is trying to use get_cycles() or
ktime_get(), after some experiments, allowing cycles/ns resolution.

(One ktime_get() per napi batch seems OK)
