From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [v2 PATCH 7/10] rhashtable: Disable automatic shrinking
Date: Mon, 23 Mar 2015 10:08:52 +0000
Message-ID: <20150323100852.GG16023@casper.infradead.org>
References: <20150322080330.GA3416@gondor.apana.org.au>
 <E1YZard-0000wE-Se@gondolin.me.apana.org.au>
 <20150322121755.GH1185@casper.infradead.org>
 <20150323000954.GB9507@gondor.apana.org.au>
 <20150323083319.GB16023@casper.infradead.org>
 <20150323092806.GA12506@gondor.apana.org.au>
 <20150323093632.GD16023@casper.infradead.org>
 <20150323093952.GA12635@gondor.apana.org.au>
 <20150323094454.GA12683@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Josh Triplett <josh@joshtriplett.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:55006 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752084AbbCWKIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 06:08:53 -0400
Content-Disposition: inline
In-Reply-To: <20150323094454.GA12683@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/23/15 at 08:44pm, Herbert Xu wrote:
> On Mon, Mar 23, 2015 at 08:39:52PM +1100, Herbert Xu wrote:
> > 
> > Because with multiple rehashing it's quite easy to convert your
> > hash table into a linked list by repeatedly growing and shrinking.
> > 
> > Multiple rehashing simply cannot work unless you get rid of automatic
> > shrinking for the untrusted case.
> 
> Actually what I could do is allow automatic shrinking when there
> are no outstanding rehashes.  So maybe we could restore this feature
> after all.

OK. Maybe this patch should be posted in the context of enabling
multiple rehashes then. It is difficult to review without having
the full context. This correlation was not clear to me from the
commit message.

I have yet to understand the implications of multiple rehashes.
The idea of having to traverse N tables for each insert, removal
and lookup in a pressure situation is still frightening.

I would like to compare it with an exponential growing logic.
Eventually both approaches can be combined to limit the chain
length of rehashes.
