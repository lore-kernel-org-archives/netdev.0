From: jamal <hadi@cyberus.ca>
Subject: Re: [NET] Fix neighbour tbl->entries race
Date: 02 Nov 2004 09:13:43 -0500
Message-ID: <1099404823.1021.15.camel@jzny.localdomain>
References: <20041102112651.GA8633@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20041102112651.GA8633@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-11-02 at 06:26, Herbert Xu wrote:
> Hi Dave:
> 
> This patch turns neigh_table's entries counter into an atomic_t.  This
> is needed since tbl->entries is updated with no locks held.  This is
> no big deal in practice since it'll be off by a few entries at most
> which is way less than any of the neighbour thresholds.
> 

Is this still the same logic:

-------------
-               if (!neigh_forced_gc(tbl) &&
-                   tbl->entries > tbl->gc_thresh3)
-                       goto out;
+               neigh_forced_gc(tbl);
+               if (atomic_read(&tbl->entries) > tbl->gc_thresh3)
+                       goto out_entries;

-------

In previous code it seems you should short-circuit if
neigh_forced_gc(tbl) returns non-zero. why do you have to break that
if statement?

cheers,
jamal
