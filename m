From: "David S. Miller" <davem@redhat.com>
Subject: Re: [ROUTE] PMTU only works on half the time
Date: Wed, 10 Dec 2003 15:15:09 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031210151509.6b48e531.davem@redhat.com>
References: <20031205124309.1490a2f4.davem@redhat.com>
	<Pine.LNX.4.44.0312060907070.1673-100000@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.44.0312060907070.1673-100000@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 6 Dec 2003 09:52:01 +0200 (EET)
Julian Anastasov <ja@ssi.bg> wrote:

> 	You are right about the case with redirects but for PMTUD
> I'm still not sure. Here is one example: host A (we) thinks
> that host B is onlink (rt_dst == rt_gateway). But host B runs
> DNAT, tunneling or cluster software and forwards the packet
> through other hosts which generate frag_needed. Such example
> is IPVS TUN mode, I now see that it is not working because IPVS
> on host B does not handle correctly the ICMP error and it can
> not reach host A - a new difficult thing to fix.

Entites that proport to provide IP services onlink, yet really
do not, need to preserve all behaviors such that they appear
to be onlink as far as other hosts can see.

This means no PMTU for onlink destinations.

> 	UDP+RTO_ONLINK+PMTUD is still valid if we want to support
> the above example setup. But I'm not sure someone will use
> such combination of parameters. Should I remove the RTO_ONLINK
> case from PMTUD?

That is what I think is best.

> 	Assume we have direct (rt_dst==rt_gateway) route with
> SCOPE_HOST and shared_media is ON (if shared media is OFF
> ip_fib_check_default already avoids SCOPE_HOST routes). I do
> not see whether the standards cover such case, our target sends redirect
> message but we are sure we hit the target IP directly. Is it supposed we
> to change rt_gateway if rt_gateway==rt_dst ? I now included
> such check in ip_rt_redirect but may be have to remove it.
> IOW, the question is whether the ICMP redirects modify only
> routes via gateway when shared_media is ON?

Interesting, I've never explored this area.  I honestly don't know,
and I will study this issue some more.

> 	OK, here is a new version, may be before the final one.
> Changes from previous version:
> 
> - removed the RTO_ONLINK case from ip_rt_redirect

OK.

> - removed the useless 'saddr && daddr' check which was added in
> previous changes

Ok.

> - added temporarily 'rth->rt_dst == rth->rt_gateway' in
> ip_rt_redirect. Is it needed?

I'll get back to you on this :)
