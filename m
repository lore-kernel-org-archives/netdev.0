From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [NET] Fix neighbour tbl->entries race
Date: Wed, 3 Nov 2004 07:37:20 +1100
Message-ID: <20041102203720.GA12108@gondor.apana.org.au>
References: <20041102112651.GA8633@gondor.apana.org.au> <1099404823.1021.15.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1099404823.1021.15.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Nov 02, 2004 at 09:13:43AM -0500, jamal wrote:
> 
> Is this still the same logic:
> 
> -------------
> -               if (!neigh_forced_gc(tbl) &&
> -                   tbl->entries > tbl->gc_thresh3)
> -                       goto out;
> +               neigh_forced_gc(tbl);
> +               if (atomic_read(&tbl->entries) > tbl->gc_thresh3)
> +                       goto out_entries;
> 
> -------
> 
> In previous code it seems you should short-circuit if
> neigh_forced_gc(tbl) returns non-zero. why do you have to break that
> if statement?

The previous logic is slightly incorrect in that even if neigh_forced_gc
succeeded in removing some entries, the total number of entries may still
be above the threshold 3.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
