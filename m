From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug in skb_segment: fskb->len != len
Date: Tue, 29 Oct 2013 21:37:38 -0700
Message-ID: <1383107858.4857.35.camel@edumazet-glaptop.roam.corp.google.com>
References: <20131028115552.GC4408@cpaasch-mac>
	 <1382966471.13037.18.camel@edumazet-glaptop.roam.corp.google.com>
	 <1383009308.5464.2.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131029144100.GA28046@gondor.apana.org.au>
	 <1383059293.5464.31.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131030015002.GB1347@gondor.apana.org.au>
	 <1383105785.4857.21.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131030040644.GA2755@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Christoph Paasch <christoph.paasch@uclouvain.be>,
	netdev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:44168 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750709Ab3J3Ehm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 00:37:42 -0400
Received: by mail-pd0-f169.google.com with SMTP id q10so415938pdj.0
        for <netdev@vger.kernel.org>; Tue, 29 Oct 2013 21:37:39 -0700 (PDT)
In-Reply-To: <20131030040644.GA2755@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-30 at 12:06 +0800, Herbert Xu wrote:

> In that case we should be able to segment these full-sized skbs
> without linearising.  What we should do is iterate through
> each frag_list entry and apply the usual GSO code to them.

Well, if you really want to be smart, we could build GSO packets of ~16
MSS, as most NIC support TSO.

So a 64K packet containing 44 MSS could be split into 3 TSO packets.
