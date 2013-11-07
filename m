From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: gso: Attempt to handle mega-GRO packets
Date: Wed, 06 Nov 2013 23:31:30 -0800
Message-ID: <1383809490.9412.50.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20131103163103.GA18894@gondor.apana.org.au>
	 <1383499603.4291.71.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131104041108.GA22823@gondor.apana.org.au>
	 <20131106013038.GA14894@gondor.apana.org.au>
	 <20131106123900.GA20259@gondor.apana.org.au>
	 <20131106133045.GA20931@gondor.apana.org.au>
	 <20131106143927.GA21604@gondor.apana.org.au>
	 <1383767241.21999.9.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131107004339.GA28156@gondor.apana.org.au>
	 <1383808262.9412.33.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131107071531.GA31857@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:57094 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752769Ab3KGHbc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 02:31:32 -0500
Received: by mail-pd0-f178.google.com with SMTP id x10so198315pdj.37
        for <netdev@vger.kernel.org>; Wed, 06 Nov 2013 23:31:31 -0800 (PST)
In-Reply-To: <20131107071531.GA31857@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-07 at 15:15 +0800, Herbert Xu wrote:

> So what in our stack violates this assumption? We've never handled
> arbitrary frag_lists in GSO and I see no reason why we need to start
> doing that now.

I do see this, skb_segment() is generic.

> 
> Also GRO was designed to only merge packets that satisfy these
> assumptions so that through GSO the original packets can be
> recovered without losing end-to-end connectivity.  This is really
> important for routers/switches.

I think we all agree on this, and we should keep this property.

The point is : skb_segment() is not tied to GRO anymore.

My patch handles virtio_net just fine, I see nothing really malicious in
virtio_net.

In particular, each skb found in the frag_list can be of any size,
and not an exact MSS multiple.

I see frag_list as a way to extend skb capacity, not as something
tied to GRO/GSO.

I worked last year so that we no longer had the frag_list being used in
GRO stack. frag_list was no longer needed, thanks to skb->head_frag
