From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: gso: Handle new frag_list of frags GRO packets
Date: Tue, 12 Nov 2013 18:17:14 -0800
Message-ID: <1384309034.28458.69.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20131106123900.GA20259@gondor.apana.org.au>
	 <20131106133045.GA20931@gondor.apana.org.au>
	 <20131106143927.GA21604@gondor.apana.org.au>
	 <1383767241.21999.9.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131107004339.GA28156@gondor.apana.org.au>
	 <20131107062234.GA31156@gondor.apana.org.au>
	 <20131107070335.GA31638@gondor.apana.org.au>
	 <20131107070647.GB31638@gondor.apana.org.au>
	 <20131111185207.GA12277@gondor.apana.org.au>
	 <1384305223.28458.58.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131113012920.GA27897@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:38034 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754491Ab3KMCRR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Nov 2013 21:17:17 -0500
Received: by mail-pa0-f46.google.com with SMTP id rd3so2704715pab.33
        for <netdev@vger.kernel.org>; Tue, 12 Nov 2013 18:17:16 -0800 (PST)
In-Reply-To: <20131113012920.GA27897@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-11-13 at 09:29 +0800, Herbert Xu wrote:

> I presume this is on a NIC that produces completely linear packets?

Sorry : with mlx4 driver, GRO builds nice skbs with one page frag per
MSS, so each skb found on frag_list is fully loaded with 16 MSS
