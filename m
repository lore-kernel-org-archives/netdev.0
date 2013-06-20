From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [patch] netfilter: prevent harmless integer overflow
Date: Thu, 20 Jun 2013 12:23:52 +0200
Message-ID: <20130620102352.GA19813@localhost>
References: <20130618074603.GF12329@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bart De Schuymer <bart.de.schuymer@pandora.be>,
	Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130618074603.GF12329@elgon.mountain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 18, 2013 at 10:46:03AM +0300, Dan Carpenter wrote:
> This overflow is harmless because a few lines later we check:
> 
> 	if (num_counters != t->private->nentries) {
> 
> But it still upsets the static checkers.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
> index 3d110c4..141350e 100644
> --- a/net/bridge/netfilter/ebtables.c
> +++ b/net/bridge/netfilter/ebtables.c
> @@ -1278,6 +1278,8 @@ static int do_update_counters(struct net *net, const char *name,
>  
>  	if (num_counters == 0)
>  		return -EINVAL;
> +	if (num_counters > INT_MAX / sizeof(*tmp))
> +		return -ENOMEM;

This is artificially limiting to INT_MAX / sizeof(struct counters).
Before this patch, the limit is UINT_MAX / sizeof(struct counters). I
think it's very unlikely to hit such a limit though, but as you
mentioned we cover the overflow already. Adding it to calm down a
static checker sound a bit too much for me.
