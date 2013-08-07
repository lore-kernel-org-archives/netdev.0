From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: Tree for Aug 7
Date: Wed, 07 Aug 2013 16:27:48 -0700 (PDT)
Message-ID: <20130807.162748.779496444843938176.davem@davemloft.net>
References: <1375893609.4004.33.camel@edumazet-glaptop>
	<20130807.104713.1615549684239408926.davem@davemloft.net>
	<20130807183758.GB16263@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, johannes@sipsolutions.net,
	sedat.dilek@gmail.com, sfr@canb.auug.org.au,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, hannes@stressinduktion.org,
	linux-wireless@vger.kernel.org, linville@tuxdriver.com
To: phil@nwl.cc
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20130807183758.GB16263@orbit.nwl.cc>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Phil Sutter <phil@nwl.cc>
Date: Wed, 7 Aug 2013 20:37:58 +0200

> One could simply call skb_push(skb, ETH_HLEN) right after calling
> eth_type_trans(skb, dev) in order to undo the 'data' and 'len'
> adjustment. Not sure if this kind of hack is the right way to go here,
> or if the whole af_packet parses ethernet header discussion should be
> opened again instead.

That's completely pointless work.

Without that header pull, the only two things left that
eth_type_trans() does is set the skb->protocol field and
set skb->dev.

And even the latter has to be done already in an else
branch in the suspect AF_PACKET code.

So this eth_type_trans() call is 2/3 duplicate or unnecessary work,
it's the completely the wrong thing to do.

Look, I'm going to fix this myself, because I'm pretty tired of
waiting for the obvious fix.
