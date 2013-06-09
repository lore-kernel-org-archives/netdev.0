From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] iptuntap: allow creation of multi-queue tun/tap device
Date: Sun, 9 Jun 2013 14:11:23 +0300
Message-ID: <20130609111123.GA16406@redhat.com>
References: <1369348589-38730-1-git-send-email-sriram.narasimhan@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: Sriram Narasimhan <sriram.narasimhan@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20100 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753231Ab3FILK4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Jun 2013 07:10:56 -0400
Content-Disposition: inline
In-Reply-To: <1369348589-38730-1-git-send-email-sriram.narasimhan@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 23, 2013 at 03:36:29PM -0700, Sriram Narasimhan wrote:
> This patch adds multi_queue option to ip tuntap.
> This allows IFF_MULTI_QUEUE flag to be specified during
> tun/tap device creation enabling multi-queue support in tun/tap
> device.
> 
> Example: ip tuntap add dev tap0 mode tap multi_queue
> 
> Signed-off-by: Sriram Narasimhan <sriram.narasimhan@hp.com>

Looks useful.

Stephen, what do you think?
Could you pick this up please?

> ---
>  ip/iptuntap.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/ip/iptuntap.c b/ip/iptuntap.c
> index 3d9ad7d..2391af2 100644
> --- a/ip/iptuntap.c
> +++ b/ip/iptuntap.c
> @@ -38,7 +38,7 @@ static void usage(void)
>  {
>  	fprintf(stderr, "Usage: ip tuntap { add | del } [ dev PHYS_DEV ] \n");
>  	fprintf(stderr, "          [ mode { tun | tap } ] [ user USER ] [ group GROUP ]\n");
> -	fprintf(stderr, "          [ one_queue ] [ pi ] [ vnet_hdr ]\n");
> +	fprintf(stderr, "          [ one_queue ] [ pi ] [ vnet_hdr ] [ multi_queue ]\n");
>  	fprintf(stderr, "\n");
>  	fprintf(stderr, "Where: USER  := { STRING | NUMBER }\n");
>  	fprintf(stderr, "       GROUP := { STRING | NUMBER }\n");
> @@ -168,6 +168,8 @@ static int parse_args(int argc, char **argv, struct ifreq *ifr, uid_t *uid, gid_
>  			ifr->ifr_flags |= IFF_ONE_QUEUE;
>  		} else if (matches(*argv, "vnet_hdr") == 0) {
>  			ifr->ifr_flags |= IFF_VNET_HDR;
> +		} else if (matches(*argv, "multi_queue") == 0) {
> +			ifr->ifr_flags |= IFF_MULTI_QUEUE;
>  		} else if (matches(*argv, "dev") == 0) {
>  			NEXT_ARG();
>  			strncpy(ifr->ifr_name, *argv, IFNAMSIZ-1);
> -- 
> 1.7.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
