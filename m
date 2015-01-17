From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 7/9] rhashtable: Per bucket locks & deferred
 expansion/shrinking
Date: Sat, 17 Jan 2015 08:06:21 +0000
Message-ID: <20150117080621.GB3968@acer.localdomain>
References: <20150116161530.GC15052@casper.infradead.org>
 <20150116163202.GJ30132@acer.localdomain>
 <063D6719AE5E284EB5DD2968C1650D6D1CACADAF@AcuExch.aculab.com>
 <20150116165302.GE15052@casper.infradead.org>
 <20150116183626.GS30132@acer.localdomain>
 <20150116191831.GA26730@casper.infradead.org>
 <20150116193557.GU30132@acer.localdomain>
 <20150116204921.GA14833@gondor.apana.org.au>
 <20150116213156.GA7109@acer.localdomain>
 <20150117003340.GA16374@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>,
	David Laight <David.Laight@ACULAB.COM>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>,
	"edumazet@google.com" <edumazet@google.com>,
	"john.r.fastabend@intel.com" <john.r.fastabend@intel.com>,
	"josh@joshtriplett.org" <josh@joshtriplett.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50296 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751981AbbAQIG1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Jan 2015 03:06:27 -0500
Content-Disposition: inline
In-Reply-To: <20150117003340.GA16374@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17.01, Herbert Xu wrote:
> On Fri, Jan 16, 2015 at 09:31:56PM +0000, Patrick McHardy wrote:
> > 
> > I'm tending towards deferring resize operations while dumps are in
> > progress. Since we only allow dumps by root, it seems the worst
> > thing that can happen is that we run using a non optimal hash,
> > which is comparable to having a badly structured ruleset.
> 
> BTW, the current rhashtable has a deficiency in that the insert
> operation never fails.  However, with delayed resizing, we must
> allow insertion to fail or there can be too many insertions that
> may overwhelm the hash table or even worse overflow the hash table
> size counter.
> 
> So in this scenario, a dump may cause insertion failures by delaying
> the completion of the expansion.

Resizing might also fail because of memory allocation problems, but
I'd argue that its better to continue with a non-optimal sized table
and retry later than to completely fail, at least unless the API
user has explicitly requested this behaviour.

As for the element counter, yeah, it should prevent overflow. In that
case I agree that failing insertion is the easiest solution.
