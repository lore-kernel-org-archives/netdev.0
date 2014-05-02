From: Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@web.de>
Subject: Re: [PATCH] bridge: simplify a
 br_multicast_query_received() function call
Date: Fri, 2 May 2014 05:14:05 +0200
Message-ID: <20140502031404.GR4593@Linus-Debian>
References: <1398106775-14857-1-git-send-email-linus.luessing@web.de>
	<20140423.144748.1259564888396787227.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20140423.144748.1259564888396787227.davem@davemloft.net>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 23, 2014 at 02:47:48PM -0400, David Miller wrote:
> > --- a/net/bridge/br_multicast.c
> > +++ b/net/bridge/br_multicast.c
> > @@ -1282,8 +1282,7 @@ static int br_ip6_multicast_query(struct net_bridge *br,
> >  		goto out;
> >  	}
> >  
> > -	br_multicast_query_received(br, port, &br->ip6_querier,
> > -				    !ipv6_addr_any(&ip6h->saddr),
> > +	br_multicast_query_received(br, port, &br->ip6_querier, 1,
> >  				    is_general_query, max_delay);
> >  
> >  	if (!group)
> 
> This doesn't make any sense to me, is_general_query can be false at this
> point.

This change has nothing to do with is_general_query, the fifth
argument. I'm modifying the fourth, the is_saddr flag. As Hannes
has pointed out here [0], now that we make sure that we have a
link-local IPv6 address at the beginning of
br_ip6_multicast_query() this implies that the source address is
not '::'.

> 
> Furthermore, even if your change would be correct, the argument is a
> boolean not an integer.

Semantically yes. Syntactically the fourth argument is an integer
at the moment (unnecessarily). Should I change 'int saddr' to
'bool saddr' while at it, within the same patch?

Cheers
