From: Patrick McHardy <kaber@trash.net>
Subject: Re: RFC: IPSEC patch 0 for netlink events
Date: Mon, 28 Mar 2005 23:23:19 +0200
Message-ID: <424875C7.3080306@trash.net>
References: <1111864971.1092.904.camel@jzny.localdomain>	 <20050326194707.GA9872@gondor.apana.org.au>	 <1111867875.1089.915.camel@jzny.localdomain>	 <20050327081848.GA13428@gondor.apana.org.au> <1111950449.1089.938.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1111950449.1089.938.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:

> @@ -478,6 +491,9 @@
>  
>  	if (x1->km.state == XFRM_STATE_ACQ) {
>  		__xfrm_state_insert(x);
> +		/* XXXX: We already have xfrm_state_lock
> +		 * do we need to grab x->lock as well? */
> +		xfrm_sa_notify(x, c, XFRM_SA_ADDED);

To answer this question: no. xfrm_state_lock can be nested in
x->lock, but not the other way around. If you want to avoid that
the state changes below you, you could notify before insertion.

Regards
Patrick
