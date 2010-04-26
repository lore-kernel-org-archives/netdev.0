From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] bnx2x: add support for receive hashing
Date: Mon, 26 Apr 2010 11:19:05 -0700
Message-ID: <u2q65634d661004261119j74042496z4f1ba570251e0c44@mail.gmail.com>
References: <alpine.DEB.1.00.1004222249400.27016@pokey.mtv.corp.google.com>
	 <1272302434.19143.76.camel@edumazet-laptop>
	 <q2o65634d661004261038t8f0c32f5ye8169ef0c38172b7@mail.gmail.com>
	 <20100426.110432.104061817.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:22885 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752583Ab0DZSTN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 14:19:13 -0400
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id o3QIJCGo001126
	for <netdev@vger.kernel.org>; Mon, 26 Apr 2010 11:19:12 -0700
Received: from pzk12 (pzk12.prod.google.com [10.243.19.140])
	by wpaz29.hot.corp.google.com with ESMTP id o3QIIjYt008074
	for <netdev@vger.kernel.org>; Mon, 26 Apr 2010 11:19:11 -0700
Received: by pzk12 with SMTP id 12so8668828pzk.32
        for <netdev@vger.kernel.org>; Mon, 26 Apr 2010 11:19:11 -0700 (PDT)
In-Reply-To: <20100426.110432.104061817.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I'm pretty sure there isn't at this point.
>
> We'll need to elide setting ->rxhash for non-TCP packets. =A0I bet th=
at
> the ETH_FAST_PATH_RX_CQE_RSS_HASH_TYPE field might be usable to makin=
g
> this decision, but if not in the worst case we'll need to parse the
> VLAN/ETH and IP4/IP6 headers to figure out the protocol.
>
> Damn, I'm so pissed off about this. =A0This ruins everything!
>
> How damn hard is it to add two 16-bit ports to the hash regardless of
> protocol?
>
=46air question.

This also hits RSS/multiqueue. In a netperf RR test, 500 streams
between my two 16 core AMDs:  TCP 970K tps, UDP 370K tps.  I'm
surprised they didn't catch that in some benchmarks...
