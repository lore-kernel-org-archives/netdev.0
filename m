From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 7/9] rhashtable: Per bucket locks & deferred
 expansion/shrinking
Date: Fri, 16 Jan 2015 15:58:35 +0000
Message-ID: <20150116155835.GA15052@casper.infradead.org>
References: <cover.1418647641.git.tgraf@suug.ch>
 <75db38bc9313a55cf02a8c36a3376c32b691e5d9.1418647641.git.tgraf@suug.ch>
 <20150116153415.GF30132@acer.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	kernel@vger.kernel.org, herbert@gondor.apana.org.au,
	paulmck@linux.vnet.ibm.com, edumazet@google.com,
	john.r.fastabend@intel.com, josh@joshtriplett.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150116153415.GF30132@acer.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/16/15 at 03:34pm, Patrick McHardy wrote:
> On 15.12, Thomas Graf wrote:
> > In the event of an expansion or shrinking, the new bucket table allocated
> > is exposed as a so called future table as soon as the resize process
> > starts.  Lookups, deletions, and insertions will briefly use both tables.
> > The future table becomes the main table after an RCU grace period and
> > initial linking of the old to the new table was performed. Optimization
> > of the chains to make use of the new number of buckets follows only the
> > new table is in use.
> 
> AFAICT nft_hash_walk() will miss new entries during this period.
> Am I missing anything here?

A walker may not see insertions that occur after the walker was started
if resizing is enabled. Is that a problem for nftables?
