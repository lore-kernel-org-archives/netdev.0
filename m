From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [22/*] [NETFILTER] Use correct IPsec MTU in TCPMSS
Date: Tue, 22 Mar 2005 19:49:10 -0800
Message-ID: <20050322194910.6a9fa3a4.davem@davemloft.net>
References: <20050214221607.GC18465@gondor.apana.org.au>
	<20050306213214.7d8a143d.davem@davemloft.net>
	<20050307103536.GB7137@gondor.apana.org.au>
	<20050308102741.GA23468@gondor.apana.org.au>
	<20050314102614.GA9610@gondor.apana.org.au>
	<20050314105313.GA21001@gondor.apana.org.au>
	<20050314111002.GA29156@gondor.apana.org.au>
	<20050315091904.GA6256@gondor.apana.org.au>
	<20050315095837.GA7130@gondor.apana.org.au>
	<20050318090310.GA28443@gondor.apana.org.au>
	<20050318091129.GA28658@gondor.apana.org.au>
	<20050318104013.57d65e99.davem@davemloft.net>
	<423D9ADA.6050407@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
        netdev@oss.sgi.com
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <423D9ADA.6050407@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 20 Mar 2005 16:46:34 +0100
Patrick McHardy <kaber@trash.net> wrote:

> So what's holding back these patches is getting some consensus on what
> exactly we want to do and finding a better method for determining when
> decapsulation is done. One possibility would be stealing packets
> in xfrm_policy_check(), but I haven't thought much about this yet.

That latter idea sounds pursuable.  I guess you'd do a netfilter
hook in xfrm_policy_check() right?

So then you'd need to pass struct sk_buff ** instead of a direct
pointer.  And that looks fine too, as nobody seems to cache
skb->XXX state across xfrm_policy_check() calls.
