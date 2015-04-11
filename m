From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 05/20] netfilter: nft_hash: add support for timeouts
Date: Sat, 11 Apr 2015 14:45:58 +0100
Message-ID: <20150411134558.GC15268@acer.localdomain>
References: <1428579304-5520-1-git-send-email-pablo@netfilter.org>
 <1428579304-5520-6-git-send-email-pablo@netfilter.org>
 <063D6719AE5E284EB5DD2968C1650D6D1CB17C7C@AcuExch.aculab.com>
 <20150411134055.GA9116@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@ACULAB.COM>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150411134055.GA9116@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11.04, Pablo Neira Ayuso wrote:
> On Thu, Apr 09, 2015 at 01:39:18PM +0000, David Laight wrote:
> > From: Pablo Neira Ayuso
> > > Sent: 09 April 2015 12:35
> > ...
> > > Add support for element timeouts to nft_hash. The lookup and walking
> > > functions are changed to ignore timed out elements, a periodic garbage
> > > collection task cleans out expired entries.
> > 
> > You probably want to delete timed out entries during insert.
> > If you do that you don't really need a garbage collector.
> 
> Exploring a synchronous solution from the Netlink API sounds like an
> interesting idea to me.

Its an optimization, but it can not replace GC. There's no guarantee
further inserts will happen.

For dynamic updates, where this is mostly needed, it won't work at all
since those happen in the wrong context. Doesn't really seem worth it.

> > I'd also worry about re-adding a timed out entry.
> 
> It seems we re-add it as a new entry.

Sure, everything except the key might be different.
