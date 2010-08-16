From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH 8/16] net/ax25: Use available error codes
Date: Mon, 16 Aug 2010 20:23:50 +0100
Message-ID: <20100816192350.GA10921@linux-mips.org>
References: <Pine.LNX.4.64.1008161826390.19313@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-hams@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Julia Lawall <julia@diku.dk>
Return-path: <linux-hams-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.1008161826390.19313@ask.diku.dk>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 16, 2010 at 06:26:57PM +0200, Julia Lawall wrote:

> From: Julia Lawall <julia@diku.dk>
> 
> Error codes are stored in err, but the return value is always 0.  Return
> err instead.
> 
> The semantic match that finds this problem is as follows:
> (http://coccinelle.lip6.fr/)
> 
> // <smpl>
> @r@
> local idexpression x;
> constant C;
> @@
> 
> if (...) { ...
>   x = -C
>   ... when != x
> (
>   return <+...x...+>;
> |
>   return NULL;
> |
>   return;
> |
> * return ...;
> )
> }
> // </smpl>
> 
> Signed-off-by: Julia Lawall <julia@diku.dk>
> 
> ---
> This changes the semantics and has not been tested.

It restores the semantics to what they should be and used to be.  This
probably happened during the introduction of proper refcounting and
locking into the AX.25 stack.  Looks fine to me.

Acked-by: Ralf Baechle <ralf@linux-mips.org>

  Ralf
