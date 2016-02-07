From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next 2/2] virtio_net: validate ethtool port setting
 and explain the user validation
Date: Sun, 7 Feb 2016 23:26:37 +0200
Message-ID: <20160207232631-mutt-send-email-mst@redhat.com>
References: <1454878344-21730-1-git-send-email-razor@blackwall.org>
 <1454878344-21730-3-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46103 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754712AbcBGV0k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Feb 2016 16:26:40 -0500
Content-Disposition: inline
In-Reply-To: <1454878344-21730-3-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 07, 2016 at 09:52:24PM +0100, Nikolay Aleksandrov wrote:
> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> We should validate the port setting that we got from the user and check
> if it's what we've set it to (PORT_OTHER), also add explanation that
> ignoring advertising is good as long as we don't have autonegotiation.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
>  drivers/net/virtio_net.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index c9fd52a8e6ec..fb0eae42bf39 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -1386,11 +1386,13 @@ static bool virtnet_validate_ethtool_cmd(const struct ethtool_cmd *cmd)
>  	struct ethtool_cmd diff1 = *cmd;
>  	struct ethtool_cmd diff2 = {};
>  
> -	/* advertising and cmd are usually set, ignore port because we set it */
> +	/* cmd is always set so we need to clear it, validate the port type
> +	 * and also without autonegotiation we can ignore advertising
> +	 */
>  	ethtool_cmd_speed_set(&diff1, 0);
> +	diff2.port = PORT_OTHER;
>  	diff1.advertising = 0;
>  	diff1.duplex = 0;
> -	diff1.port = 0;
>  	diff1.cmd = 0;
>  
>  	return !memcmp(&diff1, &diff2, sizeof(diff1));
> -- 
> 2.4.3
