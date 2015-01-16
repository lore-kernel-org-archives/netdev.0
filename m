From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 7/9] rhashtable: Per bucket locks & deferred
 expansion/shrinking
Date: Sat, 17 Jan 2015 07:49:21 +1100
Message-ID: <20150116204921.GA14833@gondor.apana.org.au>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:48650 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753185AbbAPUub (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 15:50:31 -0500
Content-Disposition: inline
In-Reply-To: <20150116193557.GU30132@acer.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 16, 2015 at 07:35:57PM +0000, Patrick McHardy wrote:
> 
> Well, rhashtable (or generally resizing) will make it a lot worse.
> Usually we at worst miss entries which were added during the dump,
> which is made up by the notifications.
> 
> With resizing we might miss anything, its completely undeterministic.

Correct.  If you want to have a stable dump you will need to have
data structure outside the hash table.  For example, with xfrm_state
we do it with a linked list.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
