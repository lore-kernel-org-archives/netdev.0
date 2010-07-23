From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [iproute2] iproute2:  Fix batch-mode for mrules.
Date: Fri, 23 Jul 2010 09:03:27 -0700
Message-ID: <20100723090327.2af5ad1f@nehalam>
References: <1279234090-18624-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48559 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754844Ab0GWQDa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jul 2010 12:03:30 -0400
In-Reply-To: <1279234090-18624-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 Jul 2010 15:48:10 -0700
Ben Greear <greearb@candelatech.com> wrote:

> The do_multirule logic was broken in batch mode because
> it expected the preferred_family to be AF_INET or AF_INET6,
> but it then assigned it to RTNL_FAMILY_IPMR or RTNL_FAMILY_IP6MR.
> So, the next iteration of the batch processing, it failed
> the check for AF_INET or AF_INET6.
> 
> Signed-off-by: Ben Greear <greearb@candelatech.com>
> ---
> :100644 100644 9c8c6ef... d3b97e2... M	ip/iprule.c
>  ip/iprule.c |    6 +++++-
>  1 files changed, 5 insertions(+), 1 deletions(-)
> 
> diff --git a/ip/iprule.c b/ip/iprule.c
> index 9c8c6ef..d3b97e2 100644
> --- a/ip/iprule.c
> +++ b/ip/iprule.c
> @@ -446,8 +446,12 @@ int do_multirule(int argc, char **argv)
>  	case AF_INET6:
>  		preferred_family = RTNL_FAMILY_IP6MR;
>  		break;
> +	case RTNL_FAMILY_IPMR:
> +	case RTNL_FAMILY_IP6MR:
> +		break;
>  	default:
> -		fprintf(stderr, "Multicast rules are only supported for IPv4/IPv6\n");
> +		fprintf(stderr, "Multicast rules are only supported for IPv4/IPv6, was: %i\n",
> +			preferred_family);
>  		exit(-1);
>  	}
>  

Applied


-- 
