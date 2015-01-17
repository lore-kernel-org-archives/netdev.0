From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 7/9] rhashtable: Per bucket locks & deferred
 expansion/shrinking
Date: Sat, 17 Jan 2015 11:33:40 +1100
Message-ID: <20150117003340.GA16374@gondor.apana.org.au>
References: <20150116160354.GI30132@acer.localdomain>
 <20150116161530.GC15052@casper.infradead.org>
 <20150116163202.GJ30132@acer.localdomain>
 <063D6719AE5E284EB5DD2968C1650D6D1CACADAF@AcuExch.aculab.com>
 <20150116165302.GE15052@casper.infradead.org>
 <20150116183626.GS30132@acer.localdomain>
 <20150116191831.GA26730@casper.infradead.org>
 <20150116193557.GU30132@acer.localdomain>
 <20150116204921.GA14833@gondor.apana.org.au>
 <20150116213156.GA7109@acer.localdomain>
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
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150116213156.GA7109@acer.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 16, 2015 at 09:31:56PM +0000, Patrick McHardy wrote:
> 
> I'm tending towards deferring resize operations while dumps are in
> progress. Since we only allow dumps by root, it seems the worst
> thing that can happen is that we run using a non optimal hash,
> which is comparable to having a badly structured ruleset.

BTW, the current rhashtable has a deficiency in that the insert
operation never fails.  However, with delayed resizing, we must
allow insertion to fail or there can be too many insertions that
may overwhelm the hash table or even worse overflow the hash table
size counter.

So in this scenario, a dump may cause insertion failures by delaying
the completion of the expansion.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
