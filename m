From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 7/9] rhashtable: Per bucket locks & deferred
 expansion/shrinking
Date: Fri, 16 Jan 2015 23:34:14 +0000
Message-ID: <20150116233414.GF20315@casper.infradead.org>
References: <20150116160354.GI30132@acer.localdomain>
 <20150116161530.GC15052@casper.infradead.org>
 <20150116163202.GJ30132@acer.localdomain>
 <063D6719AE5E284EB5DD2968C1650D6D1CACADAF@AcuExch.aculab.com>
 <20150116165302.GE15052@casper.infradead.org>
 <20150116183626.GS30132@acer.localdomain>
 <20150116191831.GA26730@casper.infradead.org>
 <20150116193557.GU30132@acer.localdomain>
 <20150116213605.GE20315@casper.infradead.org>
 <20150116220735.GA12614@acer.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@ACULAB.COM>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>,
	"edumazet@google.com" <edumazet@google.com>,
	"john.r.fastabend@intel.com" <john.r.fastabend@intel.com>,
	"josh@joshtriplett.org" <josh@joshtriplett.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150116220735.GA12614@acer.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/16/15 at 10:07pm, Patrick McHardy wrote:
> I'm afraid that's not good enough. The resize operation is deferred,
> so even if userspace does not perform an operation after starting
> the dump, the hash might change.
> 
> We can obviously work around that by incrementing a generation
> counter in rhashtable. The main problem I see is that with something
> very actively changing the ruleset, we might never complete a dump.

Right, I suggest adding a function pointer to rhashtable_params,
which when set, is called on resize so users can bump their own
sequence counter on resize.

> Dumps are usually rare, I think its preferrable to defer rehashing.

Resize operations should be *really* rare as well unless you start
with really small hash table sizes and constantly add/remove at the
watermark.

Re-dumping on insert/remove is a different story of course. Do you
care about missed insert/removals for dumps? If not we can do the
sequence number consistency checking for resizing only.
