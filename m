From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: "Badness" again
Date: Sat, 15 Jan 2005 14:13:53 +0900 (JST)
Message-ID: <20050115.141353.55181147.yoshfuji@linux-ipv6.org>
References: <41E844AC.6040200@pobox.com>
	<20050115002638.GA13849@gondor.apana.org.au>
	<20050114210651.654b22de.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, jgarzik@pobox.com, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
In-Reply-To: <20050114210651.654b22de.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20050114210651.654b22de.davem@davemloft.net> (at Fri, 14 Jan 2005 21:06:51 -0800), "David S. Miller" <davem@davemloft.net> says:

> On Sat, 15 Jan 2005 11:26:38 +1100
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > All your "badness" messages start with a call to udpv6_sendmsg().
> > That function calls ip6_dst_lookup() to get its dst entry.  Note
> > that udpv6_sendmsg() does not hold a lock on the sk at all.  However,
> > ip6_dst_lookup() uses __sk_dst_check() which is only safe if you can
> > either guarantee single-threadedness or if you hold sk_dst_lock.
> 
> Good catch, that looks to be it.

I agree too; this is one of changeset what I was going to send.
Thanks.

--yoshfuji
