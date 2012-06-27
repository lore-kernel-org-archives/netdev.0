From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH v2 net-next] tcp: avoid tx starvation by SYNACK packets
Date: Wed, 27 Jun 2012 21:50:32 +0200
Message-ID: <20120627195032.GI1269@breakpoint.cc>
References: <201206260734.33472.hans.schillstrom@ericsson.com>
 <1340730156.10893.359.camel@edumazet-glaptop>
 <1340778733.2028.110.camel@localhost>
 <20120626.235423.588696200884989114.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: brouer@redhat.com, eric.dumazet@gmail.com,
	hans.schillstrom@ericsson.com, subramanian.vijay@gmail.com,
	dave.taht@gmail.com, netdev@vger.kernel.org, ncardwell@google.com,
	therbert@google.com, mph@hoth.dk
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:35734 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754020Ab2F0Tun (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 15:50:43 -0400
Content-Disposition: inline
In-Reply-To: <20120626.235423.588696200884989114.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> From: Jesper Dangaard Brouer <brouer@redhat.com>
> Date: Wed, 27 Jun 2012 08:32:13 +0200
> 
> > Using it as default, might be "dangerous" and open an attack vector
> > on SYN cookies in Linux.
> 
> If it's dangerous for syncookies then it's just as dangerous for
> the routing hash and the socket hashes where we use it already.
> Therefore, this sounds like a baseless claim to me.

I doubt using jhash is safe for syncookies.

There a several differences to other uses in kernel:
- all hash input except u32 cookie_secret[2] is known
- we transmit hash result (i.e, its visible to 3rd party)
- we do not re-seed the secret, ever

it should be quite easy to recompute cookie_secret[] from known syncookie
values?
