From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 7/9] rhashtable: Per bucket locks & deferred
 expansion/shrinking
Date: Fri, 16 Jan 2015 21:31:56 +0000
Message-ID: <20150116213156.GA7109@acer.localdomain>
References: <20150116155835.GA15052@casper.infradead.org>
 <20150116160354.GI30132@acer.localdomain>
 <20150116161530.GC15052@casper.infradead.org>
 <20150116163202.GJ30132@acer.localdomain>
 <063D6719AE5E284EB5DD2968C1650D6D1CACADAF@AcuExch.aculab.com>
 <20150116165302.GE15052@casper.infradead.org>
 <20150116183626.GS30132@acer.localdomain>
 <20150116191831.GA26730@casper.infradead.org>
 <20150116193557.GU30132@acer.localdomain>
 <20150116204921.GA14833@gondor.apana.org.au>
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
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150116204921.GA14833@gondor.apana.org.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 17.01, Herbert Xu wrote:
> On Fri, Jan 16, 2015 at 07:35:57PM +0000, Patrick McHardy wrote:
> > 
> > Well, rhashtable (or generally resizing) will make it a lot worse.
> > Usually we at worst miss entries which were added during the dump,
> > which is made up by the notifications.
> > 
> > With resizing we might miss anything, its completely undeterministic.
> 
> Correct.  If you want to have a stable dump you will need to have
> data structure outside the hash table.  For example, with xfrm_state
> we do it with a linked list.

That's certainly one possibility, however since we might have a huge
number of elements, its very undesirable to use even a little memory
for this.

I'm tending towards deferring resize operations while dumps are in
progress. Since we only allow dumps by root, it seems the worst
thing that can happen is that we run using a non optimal hash,
which is comparable to having a badly structured ruleset.
