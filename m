From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Patch net-next v2 3/3] bridge: send query as soon as leave is
 received
Date: Tue, 30 Apr 2013 11:45:38 +0800
Message-ID: <20130430034538.GA20631@gondor.apana.org.au>
References: <1367293270-26256-1-git-send-email-amwang@redhat.com>
 <1367293270-26256-3-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Adam Baker <linux@baker-net.org.uk>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:38974 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753940Ab3D3Dpm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 23:45:42 -0400
Content-Disposition: inline
In-Reply-To: <1367293270-26256-3-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 30, 2013 at 11:41:10AM +0800, Cong Wang wrote:
> From: Cong Wang <amwang@redhat.com>
> 
> Continue sending queries when leave is received if the user marks
> it as a querier.
> 
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Adam Baker <linux@baker-net.org.uk>
> Signed-off-by: Cong Wang <amwang@redhat.com>
> ---
> v2: only send query to the port received leave
> 
>  net/bridge/br_multicast.c |    7 +++++++
>  1 files changed, 7 insertions(+), 0 deletions(-)
> 
> diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
> index bab3d5a..b1879c8 100644
> --- a/net/bridge/br_multicast.c
> +++ b/net/bridge/br_multicast.c
> @@ -1250,6 +1250,13 @@ static void br_multicast_leave_group(struct net_bridge *br,
>  	if (!mp)
>  		goto out;
>  
> +	if (br->multicast_querier) {
> +		if (port)
> +			__br_multicast_enable_port(port);
> +		else
> +			mod_timer(&br->multicast_query_timer, jiffies);
> +	}

AFAICS this is still sending a general query as opposed to a
group-specific query, no?

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
