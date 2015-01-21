From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 3/3] netlink: Lock out table resizes while dumping
 Netlink sockets
Date: Wed, 21 Jan 2015 10:23:46 +0000
Message-ID: <20150121102346.GQ20315@casper.infradead.org>
References: <e164edeacaeffee43be64d4ed6a5b5e7e8923bd1.1421759056.git.tgraf@suug.ch>
 <20150120143154.GR14883@acer.localdomain>
 <20150120145551.GH20315@casper.infradead.org>
 <20150120152149.GA3012@acer.localdomain>
 <20150120153556.GJ20315@casper.infradead.org>
 <20150121050819.GA23062@gondor.apana.org.au>
 <20150121093722.GM20315@casper.infradead.org>
 <20150121093836.GA25489@gondor.apana.org.au>
 <20150121094928.GN20315@casper.infradead.org>
 <20150121095837.GA25750@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, davem@davemloft.net,
	paulmck@linux.vnet.ibm.com, ying.xue@windriver.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:35899 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751145AbbAUKXs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2015 05:23:48 -0500
Content-Disposition: inline
In-Reply-To: <20150121095837.GA25750@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/21/15 at 08:58pm, Herbert Xu wrote:
> On Wed, Jan 21, 2015 at 09:49:28AM +0000, Thomas Graf wrote:
> >
> > An entry can move between different tables and thus chains need to be
> > marked to identify what list a lookup ended up searching in. It's not
> > the nulls marker itself that is needed, it's the bits in the last next
> > pointer identifying the list that the nulls marker allows to be used
> > which are essential.
> 
> Can you describe in more detail how it's going to be used? I don't
> see how I could use the bit if you need it to indicate the end of
> the list.

The usage will be identical to how __inet_lookup_listener() uses it.
If at the end of the lookup, we ended up in a different table than
we started, the lookup is restarted as an entry has moved to another
table while we were moving over it.
