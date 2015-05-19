From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: rhashtable: Add cap on number of elements in hash table
Date: Tue, 19 May 2015 10:25:22 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB3959A@AcuExch.aculab.com>
References: <20150515063057.GA16440@gondor.apana.org.au>
 <20150516.180946.2182730749654333791.davem@davemloft.net>
 <20150517013829.GB5161@gondor.apana.org.au>
 <20150518.161201.1959117179761854761.davem@davemloft.net>
 <20150518223526.GA25597@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "johannes@sipsolutions.net" <johannes@sipsolutions.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"tgraf@suug.ch" <tgraf@suug.ch>,
	"johannes.berg@intel.com" <johannes.berg@intel.com>
To: 'Herbert Xu' <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.195]:62293 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750834AbbESK11 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 06:27:27 -0400
In-Reply-To: <20150518223526.GA25597@gondor.apana.org.au>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu
> Sent: 18 May 2015 23:35
> On Mon, May 18, 2015 at 04:12:01PM -0400, David Miller wrote:
> >
> > Ok, this of course depends upon the distribution of the input data
> > and the strength/suitability of the hash function.
> >
> > I'm a little bit disappointed in what Thomas found.  I would expect
> > the distribution to be at least a little bit better.
> 
> Just to make it clear this is not a problem with uneven distribution.
> The same thing would happen with any hash function.  It's essentially
> a generalised birthday paradox.

Which means that with real data and a real hash function it is very
likely to be worse.
Did anyone look at what happens to the longest chains if you put
2 or 4 times as many items into the hash table?
Clearly there will be more short chains, but the longest might not
get proportionally longer (guessing at probability theory).

Personally I don't like the idea of rejecting inserts because chains
might get long, and certainly not because a malloc() fails in the
middle of the resize operation.

I'm sure there are some tables where slightly longer chains don't matter.

	David
