From: Dan Carpenter <error27@gmail.com>
Subject: Re: [Patch] net: fix an array index overflow
Date: Wed, 2 Dec 2009 15:24:27 +0200
Message-ID: <20091202132427.GE5224@bicker>
References: <20091201082901.4678.16688.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Amerigo Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754053AbZLBNYc@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091201082901.4678.16688.sendpatchset@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 01, 2009 at 03:26:02AM -0500, Amerigo Wang wrote:
> 
> Don't use the address of an out-of-boundary element.
> 
> Maybe this is not harmful at runtime, but it is still
> good to improve it.
> 
> Signed-off-by: WANG Cong <amwang@redhat.com>
> Cc: David S. Miller <davem@davemloft.net>
> 

It may be coincidence but my static checker smatch also complains 
about the code you modified.

It's the wrong idea to fix code to please a checker.  You end up
doing things like adding an extra "return -ENOTREACHED" to silence
warnings.  Then the next person who writes a checker has to figure
out how to seperate the unreachable code which was added to suppress
gcc warnings from bits which are unreachable because of typos.

Really any code that a human can read, a static checker should also
be able to read.  Computer programs are just state machines.  At 
the function level they are quite small state machines.  It's all
logic and math which computers are very good at.  So it should be 
fairly easy to fix the checker.  ;)

(The above paragraph is funnier if you knew how sucky smatch is).

regards,
dan carpenter

> ---
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index 57737b8..2669361 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -1586,7 +1586,7 @@ static int __init inet_init(void)
>  #endif
>  
>  	/* Register the socket-side information for inet_create. */
> -	for (r = &inetsw[0]; r < &inetsw[SOCK_MAX]; ++r)
> +	for (r = &inetsw[0]; r <= &inetsw[SOCK_MAX-1]; ++r)
>  		INIT_LIST_HEAD(r);
>  
>  	for (q = inetsw_array; q < &inetsw_array[INETSW_ARRAY_LEN]; ++q)
