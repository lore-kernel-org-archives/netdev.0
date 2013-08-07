From: Phil Sutter <phil@nwl.cc>
Subject: Re: linux-next: Tree for Aug 7
Date: Wed, 7 Aug 2013 20:37:58 +0200
Message-ID: <20130807183758.GB16263@orbit.nwl.cc>
References: <1375892245.4004.31.camel@edumazet-glaptop>
 <1375892522.8154.3.camel@jlt4.sipsolutions.net>
 <1375893609.4004.33.camel@edumazet-glaptop>
 <20130807.104713.1615549684239408926.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, johannes@sipsolutions.net,
	sedat.dilek@gmail.com, sfr@canb.auug.org.au,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, hannes@stressinduktion.org,
	linux-wireless@vger.kernel.org, linville@tuxdriver.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130807.104713.1615549684239408926.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 07, 2013 at 10:47:13AM -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 07 Aug 2013 09:40:09 -0700
> 
> > On Wed, 2013-08-07 at 18:22 +0200, Johannes Berg wrote:
> > 
> >> Maybe. I haven't tested it, but I'm thinking that skb->data doesn't
> >> point to the start of the data frame in this case, since we now call
> >> eth_type_trans() which pulls the ethernet header. So if the device just
> >> transmits skb->len starting from skb->data, it'll be wrong, no? That
> >> seems a basic assumption though.
> > 
> > Yes, it seems calling eth_type_trans() is not right here, and even could
> > crash.
> > 
> > Sorry, for being vague, I am a bit busy this morning.
> 
> Yes, this is absolutely the core problem, you absolute cannot
> call eth_type_trans() on the output path, it pulls off the
> ethernet header from the packet.  That can't possibly work.
> 
> I want a real fix submitted formally for this problem immediately,
> or else I'm reverting all of these changes this afternoon.

One could simply call skb_push(skb, ETH_HLEN) right after calling
eth_type_trans(skb, dev) in order to undo the 'data' and 'len'
adjustment. Not sure if this kind of hack is the right way to go here,
or if the whole af_packet parses ethernet header discussion should be
opened again instead.

Best wishes, Phil
