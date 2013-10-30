From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] net: introduce gro_frag_list_enable sysctl
Date: Tue, 29 Oct 2013 21:06:52 -0700
Message-ID: <1383106012.4857.26.camel@edumazet-glaptop.roam.corp.google.com>
References: <1383059555.5464.33.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131029.194446.2215574000648693370.davem@davemloft.net>
	 <1383094428.4857.16.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131029.220253.1263087684709722001.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: christoph.paasch@uclouvain.be, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, hkchu@google.com, mwdalton@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:41380 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750702Ab3J3EGx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 00:06:53 -0400
Received: by mail-pd0-f179.google.com with SMTP id y10so375900pdj.38
        for <netdev@vger.kernel.org>; Tue, 29 Oct 2013 21:06:53 -0700 (PDT)
In-Reply-To: <20131029.220253.1263087684709722001.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-10-29 at 22:02 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 29 Oct 2013 17:53:48 -0700
> 
> > So should we apply the first fix to avoid the BUG_ON() ?
> 
> Please be more specific, are you talking about splitting up
> this patch in some way?

I am referring to the first version I sent to Christoph :

http://www.spinics.net/lists/netdev/msg255452.html

Then I added the sysctl to avoid future packets to get a frag_list in
the first place.

Doing a smart skb_segment() is possible, but this function is already
complex.

I am not sure 64K GRO packets that must be segmented are going to be
faster than 22K packets without segmentation at all (TSO path on xmit)
