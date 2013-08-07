From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: linux-next: Tree for Aug 7
Date: Wed, 07 Aug 2013 18:22:02 +0200
Message-ID: <1375892522.8154.3.camel@jlt4.sipsolutions.net>
References: <20130807155443.a0355d0429f3e0b4ccbed261@canb.auug.org.au>
	 <CA+icZUW+uxCsvPYcY2RRvMxRVzaBLuH9u8M4ziQNWXv=nk4b2w@mail.gmail.com>
	 <20130807155918.GA16263@orbit.nwl.cc>
	 <1375891974.8154.1.camel@jlt4.sipsolutions.net>
	 <1375892245.4004.31.camel@edumazet-glaptop>
	 (sfid-20130807_181729_176093_C3201A13)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Phil Sutter <phil@nwl.cc>, Sedat Dilek <sedat.dilek@gmail.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	wireless <linux-wireless@vger.kernel.org>,
	John Linville <linville@tuxdriver.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1375892245.4004.31.camel@edumazet-glaptop> (sfid-20130807_181729_176093_C3201A13)
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-08-07 at 09:17 -0700, Eric Dumazet wrote:
> On Wed, 2013-08-07 at 18:12 +0200, Johannes Berg wrote:
> > On Wed, 2013-08-07 at 17:59 +0200, Phil Sutter wrote:
> > 
> > > The idea behind this patch is that users setting the protocol to
> > > something else probably do know better and so should be left alone.
> > 
> > Regardless of that, I think that still the skb pointers would be changed
> > by this patch which would confuse the receiver of the SKB (device
> > driver), no? Has anyone verified that theory? :)
> 
> Maybe receivers made wrong assumptions about some headers being set or
> not set ?

Maybe. I haven't tested it, but I'm thinking that skb->data doesn't
point to the start of the data frame in this case, since we now call
eth_type_trans() which pulls the ethernet header. So if the device just
transmits skb->len starting from skb->data, it'll be wrong, no? That
seems a basic assumption though.

johannes
