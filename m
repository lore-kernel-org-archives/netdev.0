From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: gso: Attempt to handle mega-GRO packets
Date: Wed, 06 Nov 2013 11:47:21 -0800
Message-ID: <1383767241.21999.9.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1383091610.1534.29.camel@bwh-desktop.uk.level5networks.com>
	 <1383400897.4291.47.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131103122824.GA17394@gondor.apana.org.au>
	 <1383496104.4291.69.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131103163103.GA18894@gondor.apana.org.au>
	 <1383499603.4291.71.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131104041108.GA22823@gondor.apana.org.au>
	 <20131106013038.GA14894@gondor.apana.org.au>
	 <20131106123900.GA20259@gondor.apana.org.au>
	 <20131106133045.GA20931@gondor.apana.org.au>
	 <20131106143927.GA21604@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f169.google.com ([209.85.216.169]:57339 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752017Ab3KFTrZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 14:47:25 -0500
Received: by mail-qc0-f169.google.com with SMTP id x12so6427556qcv.28
        for <netdev@vger.kernel.org>; Wed, 06 Nov 2013 11:47:25 -0800 (PST)
In-Reply-To: <20131106143927.GA21604@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-11-06 at 22:39 +0800, Herbert Xu wrote:

> In fact, we never relied on the frag_list having headers anyway so
> it's not hard to fix this.
> 
> Still totally untested but at least this has a chance of handling
> the new virtio_net.

First try, machine doesn't crash, but things are not working.

[  433.232553] skbuff: skb_segment: illegal GSO fragment: 1514 1448
[  433.340523] skbuff: skb_segment: illegal GSO fragment: 1514 1448skbuff: skb_segment: illegal GSO fragment: 1514 1448
[  433.340578] skbuff: skb_segment: illegal GSO fragment: 1514 1448skbuff: skb_segment: illegal GSO fragment: 1514 1448
[  433.340598] skbuff: skb_segment: illegal GSO fragment: 1514 1448skbuff: skb_segment: illegal GSO fragment: 1514 1448
[  433.340620] skbuff: skb_segment: illegal GSO fragment: 1514 1448skbuff: skb_segment: illegal GSO fragment: 1514 1448
[  433.340661] skbuff: skb_segment: illegal GSO fragment: 1514 1448<4>[  438.313019] net_ratelimit: 141 callbacks suppressed

To test this, I used a regular forwarding path between three hosts

A --->  B ----> C

I'll try a different way.

The frag_list would contain a bunch of frags, that we logically add to the bunch
of frags found in the first skb shared_info structure.

Thanks
