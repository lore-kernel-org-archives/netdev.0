From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 2/2] [IPV4] route: Dynamic hash table sizing.
Date: Wed, 9 Aug 2006 10:32:54 +0200
Message-ID: <200608091032.55232.dada1@cosmosbay.com>
References: <20060809.004920.59469729.davem@davemloft.net> <20060809.005337.104642177.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:43197 "EHLO pfx2.jmh.fr")
	by vger.kernel.org with ESMTP id S1030451AbWHIIc4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 04:32:56 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060809.005337.104642177.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 09 August 2006 09:53, David Miller wrote:
> [IPV4] route: Dynamic hash table sizing.
>

 Excellent work David, Thank you !!!

> +static int ip_rt_hashsz_limit		= (8 * 1024 * 1024) / sizeof(void *);

__read_mostly ?




> +		hash = __rt_hash_code(list->fl.fl4_dst,
> +				      list->fl.fl4_src &
> +				      (iface << 5),
> +				      nhashmask);

I thought it was a XOR (^) , not a AND (&)


>  static int __init set_rhash_entries(char *str)
>  {
> +	unsigned long val;
> +
>  	if (!str)
>  		return 0;
> -	rhash_entries = simple_strtoul(str, &str, 0);
> +	val = simple_strtoul(str, &str, 0);
> +
> +	/* Only use it if it's a power-of-2. */
> +	if (!(val & (val - 1)))
> +		rhash_entries = val;
> +

Well, it breaks x86_64 machines that currently do rhash_entries=2000000
Why not round to the next/previous power of two as before ?

>  	return 1;
>  }
>  __setup("rhash_entries=", set_rhash_entries);
>

Thank you
Eric
