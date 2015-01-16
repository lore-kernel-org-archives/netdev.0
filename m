From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 7/9] rhashtable: Per bucket locks & deferred
 expansion/shrinking
Date: Fri, 16 Jan 2015 19:18:31 +0000
Message-ID: <20150116191831.GA26730@casper.infradead.org>
References: <cover.1418647641.git.tgraf@suug.ch>
 <75db38bc9313a55cf02a8c36a3376c32b691e5d9.1418647641.git.tgraf@suug.ch>
 <20150116153415.GF30132@acer.localdomain>
 <20150116155835.GA15052@casper.infradead.org>
 <20150116160354.GI30132@acer.localdomain>
 <20150116161530.GC15052@casper.infradead.org>
 <20150116163202.GJ30132@acer.localdomain>
 <063D6719AE5E284EB5DD2968C1650D6D1CACADAF@AcuExch.aculab.com>
 <20150116165302.GE15052@casper.infradead.org>
 <20150116183626.GS30132@acer.localdomain>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:46006 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757068AbbAPTSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 14:18:36 -0500
Content-Disposition: inline
In-Reply-To: <20150116183626.GS30132@acer.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/16/15 at 06:36pm, Patrick McHardy wrote:
> On 16.01, Thomas Graf wrote:
> > On 01/16/15 at 04:43pm, David Laight wrote:
> > > The walker is unlikely to see items that get inserted early in the hash
> > > table even without a resize.
> > 
> > I don't follow, you have to explain this statement.
> > 
> > Walkers which don't want to see duplicates or miss entries should
> > just take the mutex.
> 
> Well, we do have a problem with interrupted dumps. As you know once
> the netlink message buffer is full, we return to userspace and
> continue dumping during the next read. Expanding obviously changes
> the order since we rehash from bucket N to N and 2N, so this will
> indeed cause duplicate (doesn't matter) and missed entries.

Right,but that's a Netlink dump issue and not specific to rhashtable.
Putting the sequence number check in place should be sufficient
for sets, right?
