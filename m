From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [NET] Fix neighbour tbl->entries race
Date: Wed, 03 Nov 2004 10:14:03 +0900 (JST)
Message-ID: <20041103.101403.118617263.yoshfuji@linux-ipv6.org>
References: <1099404823.1021.15.camel@jzny.localdomain>
	<20041102203720.GA12108@gondor.apana.org.au>
	<20041102210259.GA12642@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, davem@davemloft.net, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <20041102210259.GA12642@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20041102210259.GA12642@gondor.apana.org.au> (at Wed, 3 Nov 2004 08:02:59 +1100), Herbert Xu <herbert@gondor.apana.org.au> says:

> -	if (tbl->entries > tbl->gc_thresh3 ||
> -	    (tbl->entries > tbl->gc_thresh2 &&
> +	entries = atomic_inc_return(&tbl->entries) - 1;
> +	if (entries >= tbl->gc_thresh3 ||
> +	    (entries >= tbl->gc_thresh2 &&

Why don't you do something like this?

        entries = atomic_inc_return(&tbl->entries);
        if (entries > tbl->gc_thresh3 ||
            (entries > tbl->gc_thresh2 &&

--yoshfuji
