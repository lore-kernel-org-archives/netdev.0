From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Re-routing packets via netfilter (ip_rt_bug)
Date: Wed, 27 Apr 2005 09:28:57 +1000
Message-ID: <20050426232857.GA18358@gondor.apana.org.au>
References: <E1DQ1Ct-00055s-00@gondolin.me.apana.org.au>
	<426D0CB9.4060500@trash.net>
	<20050425213400.GB29288@gondor.apana.org.au>
	<426D8672.1030001@trash.net>
	<20050426003925.GA13650@gondor.apana.org.au>
	<426E3F67.8090006@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org, Yair@arx.com,
	linux-kernel@vger.kernel.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <426E3F67.8090006@trash.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 26, 2005 at 03:17:27PM +0200, Patrick McHardy wrote:
> 
> Looks like we have no choice but to also use saddr=0 and
> ip_route_output() in this case.

Let's look at the bigger picture.  There are three users of
ip_route_me_harder: nat, mangle and queue.  They're all done
in LOCAL_OUT.

For nat/mangle, the source address cannot change so it's
guaranteed to be a local IP address.  On the face of it,
queue could be changing the source address.  However, the
more I think about it the more I reckon that it should
be disallowed.

If the user is changing the source address in LOCAL_OUT/queue
then he's doing SNAT in LOCAL_OUT.  This violates some fundamental
assumptions in netfilter.  The user also isn't going to have
an easy time setting up the reverse DNAT since the corresponding
location on the reverse side does not have a ip_route_me_harder
call.

Even if there is really a demand for SNAT in LOCAL_OUT, we
should probably be implementing it properly rather than having
the user craft their own in user-space.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
