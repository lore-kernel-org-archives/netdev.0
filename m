From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] net: introduce gro_frag_list_enable sysctl
Date: Sat, 02 Nov 2013 11:28:27 -0700
Message-ID: <1383416907.4291.52.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20131029.220253.1263087684709722001.davem@davemloft.net>
	 <20131030020543.GA1925@gondor.apana.org.au>
	 <CAPshTCgykFMa=4rnQ3TKa2cfgWYj4TgByO2GbzLzq71Y_=oc=Q@mail.gmail.com>
	 <20131029.223331.1745589461091527596.davem@davemloft.net>
	 <44571383414236@web13j.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"hkchu@google.com" <hkchu@google.com>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"christoph.paasch@uclouvain.be" <christoph.paasch@uclouvain.be>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"mwdalton@google.com" <mwdalton@google.com>
To: "Oleg A.Arkhangelsky" <sysoleg@yandex.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:55261 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753525Ab3KBS23 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Nov 2013 14:28:29 -0400
Received: by mail-pa0-f47.google.com with SMTP id lf10so5309063pab.6
        for <netdev@vger.kernel.org>; Sat, 02 Nov 2013 11:28:29 -0700 (PDT)
In-Reply-To: <44571383414236@web13j.yandex.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-11-02 at 21:43 +0400, Oleg A.Arkhangelsky wrote:
> 
> 30.10.2013, 06:33, "David Miller" <davem@davemloft.net>:
> 
> > GRO should always win, even on a router, because it decreases the
> > number of fundamental operations (routing lookups) that the stack
> > needs to perform.
> 
> Yes, unless the case when you're using Linux as IP router which is
> forwarding 500K mixed IP (TCP and UDP) flows traffic @ 10-20 Gbit/s.
> Then GRO is unnecessarily overhead, cause there's no possibility to
> accumulate adequate GRO list in such scenario.
> 

This was assuming the aggregation factor was not 0.

Even with 500K flows, you can have typically bursts of two packets per
flow.

Thats one of the reason why I chose to default
/proc/sys/net/ipv4/tcp_min_tso_segs to 2
