From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 7/9] rhashtable: Per bucket locks & deferred
 expansion/shrinking
Date: Fri, 16 Jan 2015 21:36:05 +0000
Message-ID: <20150116213605.GE20315@casper.infradead.org>
References: <20150116153415.GF30132@acer.localdomain>
 <20150116155835.GA15052@casper.infradead.org>
 <20150116160354.GI30132@acer.localdomain>
 <20150116161530.GC15052@casper.infradead.org>
 <20150116163202.GJ30132@acer.localdomain>
 <063D6719AE5E284EB5DD2968C1650D6D1CACADAF@AcuExch.aculab.com>
 <20150116165302.GE15052@casper.infradead.org>
 <20150116183626.GS30132@acer.localdomain>
 <20150116191831.GA26730@casper.infradead.org>
 <20150116193557.GU30132@acer.localdomain>
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
Received: from casper.infradead.org ([85.118.1.10]:46469 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751537AbbAPVgJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 16:36:09 -0500
Content-Disposition: inline
In-Reply-To: <20150116193557.GU30132@acer.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/16/15 at 07:35pm, Patrick McHardy wrote:
> On 16.01, Thomas Graf wrote:
> > Right,but that's a Netlink dump issue and not specific to rhashtable.
> 
> Well, rhashtable (or generally resizing) will make it a lot worse.
> Usually we at worst miss entries which were added during the dump,
> which is made up by the notifications.
> 
> With resizing we might miss anything, its completely undeterministic.
> 
> > Putting the sequence number check in place should be sufficient
> > for sets, right?
> 
> I don't see how. The problem is that the ordering of the hash changes
> and it will skip different entries than those that have already been
> dumped.

Since an resize can only be triggered through insert/remove you
simply bump a sequence number when you insert/remove and have
userspace restart the dump when NLM_F_DUMP_INTR is set.
