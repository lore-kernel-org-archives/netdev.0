From: "David S. Miller" <davem@davemloft.net>
Subject: Re: "Badness" again
Date: Fri, 14 Jan 2005 21:06:51 -0800
Message-ID: <20050114210651.654b22de.davem@davemloft.net>
References: <41E83B8D.8020003@pobox.com>
	<20050114215833.GA12981@gondor.apana.org.au>
	<41E844AC.6040200@pobox.com>
	<20050115002638.GA13849@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050115002638.GA13849@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 15 Jan 2005 11:26:38 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> All your "badness" messages start with a call to udpv6_sendmsg().
> That function calls ip6_dst_lookup() to get its dst entry.  Note
> that udpv6_sendmsg() does not hold a lock on the sk at all.  However,
> ip6_dst_lookup() uses __sk_dst_check() which is only safe if you can
> either guarantee single-threadedness or if you hold sk_dst_lock.

Good catch, that looks to be it.

I wouldn't have caught the necessary dst_hold(*dst) removal
too, in fact I thought this hunk of your patch was a bug at
first :-)

I'll apply this, thanks a lot Herbert.
