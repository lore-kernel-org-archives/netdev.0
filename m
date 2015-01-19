From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 7/9] rhashtable: Per bucket locks & deferred
 expansion/shrinking
Date: Mon, 19 Jan 2015 09:45:58 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CACBF27@AcuExch.aculab.com>
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
 <20150116213605.GE20315@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>,
	"edumazet@google.com" <edumazet@google.com>,
	"john.r.fastabend@intel.com" <john.r.fastabend@intel.com>,
	"josh@joshtriplett.org" <josh@joshtriplett.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
To: 'Thomas Graf' <tgraf@suug.ch>, Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.184]:50481 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751194AbbASJrt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 04:47:49 -0500
In-Reply-To: <20150116213605.GE20315@casper.infradead.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf
> On 01/16/15 at 07:35pm, Patrick McHardy wrote:
> > On 16.01, Thomas Graf wrote:
> > > Right,but that's a Netlink dump issue and not specific to rhashtable.
> >
> > Well, rhashtable (or generally resizing) will make it a lot worse.
> > Usually we at worst miss entries which were added during the dump,
> > which is made up by the notifications.
> >
> > With resizing we might miss anything, its completely undeterministic.
> >
> > > Putting the sequence number check in place should be sufficient
> > > for sets, right?
> >
> > I don't see how. The problem is that the ordering of the hash changes
> > and it will skip different entries than those that have already been
> > dumped.
> 
> Since an resize can only be triggered through insert/remove you
> simply bump a sequence number when you insert/remove and have
> userspace restart the dump when NLM_F_DUMP_INTR is set.

You could suppress 'shrink' while a userspace dump is in progress
and force userspace to restart on 'grow'.

The suppress does rather require that you know when any userspace 'walk'
gives up. OTOH it should be possible to defer the 'shrink' everytime
a walk reads some more of the data.

	David
