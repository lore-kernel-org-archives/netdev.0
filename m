From: =?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kvGyRCNUhGIzFRTEAbKEI=?=
	<hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH] neighbour: Convert if statment in the function, neigh_add_timer
 to a WARN_ON
Date: Tue, 02 Jun 2015 11:37:40 +0900
Message-ID: <556D16F4.3060307@miraclelinux.com>
References: <1433188983-23207-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com, ebiederm@xmission.com,
	edumazet@google.com, xiyou.wangcong@gmail.com,
	yoshfuji@linux-ipv6.org, johannes.berg@intel.com,
	nicolas.dichtel@6wind.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Nicholas Krause <xerofoify@gmail.com>, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1433188983-23207-1-git-send-email-xerofoify@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nicholas Krause wrote:
> This converts the if statement for dumping the stack into a
> WARN_ON in order to make this function's debugging check
> simpler and have a cleaner output when this condition
> occurs inside this function for when bugs related to
> adding a duplicate neighbour table timer arise.
> 
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---
>  net/core/neighbour.c | 6 +-----
>  1 file changed, 1 insertion(+), 5 deletions(-)
> 
> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
> index 3de6542..0bf71da 100644
> --- a/net/core/neighbour.c
> +++ b/net/core/neighbour.c
> @@ -165,11 +165,7 @@ static int neigh_forced_gc(struct neigh_table *tbl)
>  static void neigh_add_timer(struct neighbour *n, unsigned long when)
>  {
>  	neigh_hold(n);
> -	if (unlikely(mod_timer(&n->timer, when))) {
> -		printk("NEIGH: BUG, double timer add, state is %x\n",
> -		       n->nud_state);
> -		dump_stack();
> -	}
> +	WARN_ON(unlikely(mod_timer(&n->timer, when)));
>  }

NACK, please do not use WARN_ON for things with side effects.

--yoshfuji
