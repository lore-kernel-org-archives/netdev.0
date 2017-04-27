From: Greg Rose <gvrose8192@gmail.com>
Subject: Re: [PATCH net-next] net: vrf: Do not allow looback to be moved to
 a VRF
Date: Wed, 26 Apr 2017 19:44:25 -0700
Message-ID: <1493261065.4737.5.camel@gmail.com>
References: <1493218702-10906-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rshearma@brocade.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35581 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1033605AbdD0Co3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 22:44:29 -0400
Received: by mail-pf0-f194.google.com with SMTP id a188so4956408pfa.2
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 19:44:28 -0700 (PDT)
In-Reply-To: <1493218702-10906-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-04-26 at 07:58 -0700, David Ahern wrote:
> Moving the loopback into a VRF breaks networking for the default VRF.
> Since the VRF device is the loopback for VRF domains, there is no
> reason to move the loopback. Given the repercussions, block attempts
> to set lo into a VRF.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
>  drivers/net/vrf.c | 6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
> index aa5d30428bba..ceda5861da78 100644
> --- a/drivers/net/vrf.c
> +++ b/drivers/net/vrf.c
> @@ -877,6 +877,12 @@ static int do_vrf_add_slave(struct net_device *dev, struct net_device *port_dev)
>  {
>  	int ret;
>  
> +	/* do not allow loopback device to be enslaved to a VRF.
> +	 * The vrf device acts as the loopback for the vrf.
> +	 */
> +	if (port_dev == dev_net(dev)->loopback_dev)
> +		return -EOPNOTSUPP;
> +
>  	port_dev->priv_flags |= IFF_L3MDEV_SLAVE;
>  	ret = netdev_master_upper_dev_link(port_dev, dev, NULL, NULL);
>  	if (ret < 0)

I think that's a great idea.

Reviewed-by: Greg Rose <gvrose8192@gmail.com>
