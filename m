From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Move fib_alias out of fib_hash.c
Date: Wed, 29 Sep 2004 23:30:48 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16731.10632.290408.265135@robur.slu.se>
References: <20040928214722.11aef8e0.davem@davemloft.net>
	<16730.53965.503605.943263@robur.slu.se>
	<20040929125359.12a00ba7.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040929125359.12a00ba7.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


David S. Miller writes:

 > You cannot find the longest matching prefix and just use that.
 > 
 > Rather, you must iterate through all matching prefixes in the
 > table from longest to shortest, trying fib_semantic_match() on
 > each one until it says OK.

 You're right we have to match semantics then first after that return 
 longest prefix to comply w. current matching.


 > This makes using a new algorithm very non-trivial.

 Yes and will take resources compared to simple longest prefix.

 > Probably what you should do is keep an array on the function
 > stack, recording shorter prefix entries you see on your walk
 > down to the longest matching prefix.  Then you process the array
 > one entry at a time back to the root, trying fib_semantic_match()
 > on each one.

 We have backtracking as we search to leaves and as leaves does not 
 always has a matching prefix.  So we have to look into how semantics 
 match can be done here instead and backtrack until we got a semantics 
 match. Was about to test w. ipv6 to start with due to ipv4 complexity.
 Anyway ipv4 fib-code is cleaner now.

 Cheers.
						--ro
  
