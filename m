From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] IP_GRE: Linearize skb before csum.
Date: Tue, 22 Jan 2013 21:30:50 -0800
Message-ID: <1358919050.12374.733.camel@edumazet-glaptop>
References: <20130122.204629.607263597214211092.davem@davemloft.net>
	 <20130122.232235.643904201225800004.davem@davemloft.net>
	 <1358917373.12374.707.camel@edumazet-glaptop>
	 <20130123.001956.1988771856502410155.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jesse@nicira.com, pshelar@nicira.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:43275 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752867Ab3AWFax (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 00:30:53 -0500
Received: by mail-pb0-f44.google.com with SMTP id uo1so4457232pbc.17
        for <netdev@vger.kernel.org>; Tue, 22 Jan 2013 21:30:53 -0800 (PST)
In-Reply-To: <20130123.001956.1988771856502410155.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-01-23 at 00:19 -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 22 Jan 2013 21:02:53 -0800
> 
> > GSO was a bad idea from the very beginning, if you want
> > such use case. 
> 
> It's perfectly fine when the card checksums the packet.  Because it
> will checksum the exact data that will hit the wire and thus the
> checksum will be correct always.
> 
> It's only buggy when we do pure software GSO and have page frags.

Right.

We could add a new SKB_GSO_SHARED_FRAG bit for that, and force an extra
copy of frags, instead of a linearize call.

Basically, splice(pipe -> socket)/sendfile()/vmsplice() should set this
flag.

Its a bit late here, I'll do that tomorrow.
