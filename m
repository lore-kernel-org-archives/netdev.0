From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [v2 PATCH 3/10] rhashtable: Allow hashfn to be unset
Date: Mon, 23 Mar 2015 14:29:41 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB079DB@AcuExch.aculab.com>
References: <20150322080330.GA3416@gondor.apana.org.au>
 <E1YZarZ-0000v8-7e@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'Herbert Xu' <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Josh Triplett <josh@joshtriplett.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.185]:53842 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752182AbbCWObV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 10:31:21 -0400
In-Reply-To: <E1YZarZ-0000v8-7e@gondolin.me.apana.org.au>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu
> Since every current rhashtable user uses jhash as their hash
> function, the fact that jhash is an inline function causes each
> user to generate a copy of its code.
> 
> This function provides a solution to this problem by allowing
> hashfn to be unset.  In which case rhashtable will automatically
> set it to jhash.  Furthermore, if the key length is a multiple
> of 4, we will switch over to jhash2.

Would it make sense to do this as a run-time check for the NULL
function pointer so that the jhash code itself can be inlined?

The cost of the test is likely to be less that the indirect call.

	David
