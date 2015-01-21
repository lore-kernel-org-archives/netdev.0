From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 3/3] netlink: Lock out table resizes while dumping
 Netlink sockets
Date: Wed, 21 Jan 2015 09:49:28 +0000
Message-ID: <20150121094928.GN20315@casper.infradead.org>
References: <cover.1421759056.git.tgraf@suug.ch>
 <e164edeacaeffee43be64d4ed6a5b5e7e8923bd1.1421759056.git.tgraf@suug.ch>
 <20150120143154.GR14883@acer.localdomain>
 <20150120145551.GH20315@casper.infradead.org>
 <20150120152149.GA3012@acer.localdomain>
 <20150120153556.GJ20315@casper.infradead.org>
 <20150121050819.GA23062@gondor.apana.org.au>
 <20150121093722.GM20315@casper.infradead.org>
 <20150121093836.GA25489@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, davem@davemloft.net,
	paulmck@linux.vnet.ibm.com, ying.xue@windriver.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150121093836.GA25489@gondor.apana.org.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/21/15 at 08:38pm, Herbert Xu wrote:
> On Wed, Jan 21, 2015 at 09:37:22AM +0000, Thomas Graf wrote:
> >
> > Without having seen your code, can we make it configurable on what
> > the bit is used for? Use of nulls marker is a strict requirement for
> > some targeted users of rhashtable.
> 
> What do they need this for?

An entry can move between different tables and thus chains need to be
marked to identify what list a lookup ended up searching in. It's not
the nulls marker itself that is needed, it's the bits in the last next
pointer identifying the list that the nulls marker allows to be used
which are essential.

This is on my plate next. Most of the work in rhashtable was done in
preparation of translating the TCP established table over to
rhashtable.
