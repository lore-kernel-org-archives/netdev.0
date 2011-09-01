From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [patch net-next-2.6] br: remove redundant check and init
Date: Thu, 1 Sep 2011 09:07:41 -0700
Message-ID: <20110901090741.4ce49e76@nehalam.ftrdhcpuser.net>
References: <1314883778-2706-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, bridge@lists.linux-foundation.org
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35356 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932571Ab1IAQHb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Sep 2011 12:07:31 -0400
In-Reply-To: <1314883778-2706-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  1 Sep 2011 15:29:38 +0200
Jiri Pirko <jpirko@redhat.com> wrote:

> Since these checks and initialization are done in
> dev_ethtool_get_settings called later on, remove this redundancy.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> ---
>  net/bridge/br_if.c |   24 +++++++++++-------------
>  1 files changed, 11 insertions(+), 13 deletions(-)
> 
> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
> index 2cdf007..b365bba 100644
> --- a/net/bridge/br_if.c
> +++ b/net/bridge/br_if.c
> @@ -33,20 +33,18 @@
>   */
>  static int port_cost(struct net_device *dev)
>  {
> -	if (dev->ethtool_ops && dev->ethtool_ops->get_settings) {
> -		struct ethtool_cmd ecmd = { .cmd = ETHTOOL_GSET, };
> -
> -		if (!dev_ethtool_get_settings(dev, &ecmd)) {
> -			switch (ethtool_cmd_speed(&ecmd)) {
> -			case SPEED_10000:
> -				return 2;
> -			case SPEED_1000:
> -				return 4;
> -			case SPEED_100:
> -				return 19;
> -			case SPEED_10:
> -				return 100;
> -			}
> +	struct ethtool_cmd ecmd;
> +
> +	if (!dev_ethtool_get_settings(dev, &ecmd)) {
> +		switch (ethtool_cmd_speed(&ecmd)) {
> +		case SPEED_10000:
> +			return 2;
> +		case SPEED_1000:
> +			return 4;
> +		case SPEED_100:
> +			return 19;
> +		case SPEED_10:
> +			return 100;
>  		}
>  	}
>  

Yeah, this code predates when ethtool was sane about ops

Acked-by: Stephen Hemminger <shemminger@vyatta.com>
