From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] net: introduce gro_frag_list_enable sysctl
Date: Tue, 29 Oct 2013 21:16:17 -0700
Message-ID: <1383106577.4857.30.camel@edumazet-glaptop.roam.corp.google.com>
References: <1383059555.5464.33.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131029.194446.2215574000648693370.davem@davemloft.net>
	 <1383094428.4857.16.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131029.220253.1263087684709722001.davem@davemloft.net>
	 <1383106012.4857.26.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131030040818.GB2755@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, christoph.paasch@uclouvain.be,
	netdev@vger.kernel.org, hkchu@google.com, mwdalton@google.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:48400 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750702Ab3J3EQT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 00:16:19 -0400
Received: by mail-pa0-f43.google.com with SMTP id hz1so346875pad.16
        for <netdev@vger.kernel.org>; Tue, 29 Oct 2013 21:16:19 -0700 (PDT)
In-Reply-To: <20131030040818.GB2755@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-30 at 12:08 +0800, Herbert Xu wrote:
> On Tue, Oct 29, 2013 at 09:06:52PM -0700, Eric Dumazet wrote:
> >
> > I am not sure 64K GRO packets that must be segmented are going to be
> > faster than 22K packets without segmentation at all (TSO path on xmit)
> 
> Indeed that is a tough call, but I think conceptually the 64K
> case is much nicer than a sysctl that gets magically turned off.

The thing is this only matters for hosts receiving at line rate on few
TCP flows.

A router should not build too big GRO packets, as it adds latencies.

Really, we had to make TSO packets being auto sized, lets not add the
syndrome again.

So I do not really understand David concern about emitting a warning.

If a machine is used as a router, building GRO packets of 17 MSS is
absolutely fine.
