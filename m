From: Russell Stuart <russell-lartc@stuart.id.au>
Subject: Re: [PATCH] TC: bug fixes to the "sample" clause
Date: Tue, 14 Mar 2006 12:45:59 +1000
Message-ID: <1142304359.17608.149.camel@ras.pc.brisbane.lube>
References: <1139538806.15476.33.camel@ras> <1142082696.5184.53.camel@jzny2>
	<1142085718.5184.73.camel@jzny2>
	<1142088594.4199.115.camel@ras.pc.stuart.local>
	<1142092598.5184.93.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lartc@mailman.ds9a.nl
Return-path: <lartc-bounces@mailman.ds9a.nl>
To: hadi@cyberus.ca
In-Reply-To: <1142092598.5184.93.camel@jzny2>
List-Unsubscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=unsubscribe>
List-Archive: <http://mailman.ds9a.nl/pipermail/lartc>
List-Post: <mailto:lartc@mailman.ds9a.nl>
List-Help: <mailto:lartc-request@mailman.ds9a.nl?subject=help>
List-Subscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=subscribe>
Sender: lartc-bounces@mailman.ds9a.nl
Errors-To: lartc-bounces@mailman.ds9a.nl
List-Id: netdev.vger.kernel.org

On Sat, 2006-03-11 at 10:56 -0500, jamal wrote:
> Right - take a look at the use of hashkey with varying divisors to see
> where the 2.4 folding breaks[1]. Note you should be able to use hashkey
> instead of sample and it would work fine.

<snip>

> [1] Essentially, if you teach u32 in 2.4 to spread rules over different
> buckets it will not do so evenly. Off top of my head i remember that the
> best you could ever do is have bucket selection in increments of 4 (so
> bucket 0, 4, 8,..) with certain divisor sizes - mostly works with 256;
> to work properly you need it to be (0,1,2,3,..). 
> implies --> When it does work, it is detrimental to lookup speed when
> you hit thousands of rules because some buckets get overloaded and
> others are totaly unused and when it doesnt work, it results in
> classifier misses for rules you inserted. 

Hmm.  I can't see how this could be so.  Can you give 
specific examples.

The only time I can think of where the 2.4 XOR hash would
be worse is where there is a correlation between the bits
in different bytes.  I can't think of a real life example
of where that would be so.  In every other case it will
be as good as, but typically better than, the 2.6
algorithm.
