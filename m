From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next V2 2/2] net/mlx4_en: Add netdev support for
 TCP/IP offloads of vxlan tunneling
Date: Sun, 22 Dec 2013 15:32:39 -0800
Message-ID: <1387755159.22671.27.camel@joe-AO722>
References: <1387725972-10244-1-git-send-email-ogerlitz@mellanox.com>
	 <1387725972-10244-3-git-send-email-ogerlitz@mellanox.com>
	 <20131222.181202.168681767663560253.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: ogerlitz@mellanox.com, netdev@vger.kernel.org, amirv@mellanox.com,
	yanb@mellanox.com, ast@plumgrid.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0123.hostedemail.com ([216.40.44.123]:50382 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756087Ab3LVXco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 18:32:44 -0500
In-Reply-To: <20131222.181202.168681767663560253.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-12-22 at 18:12 -0500, David Miller wrote:
> From: Or Gerlitz <ogerlitz@mellanox.com>
> Date: Sun, 22 Dec 2013 17:26:12 +0200
> 
> > +	if ((mdev->dev->caps.tunnel_offload_mode == MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)) {
> > +	if ((mdev->dev->caps.tunnel_offload_mode == MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)) {
> > +	if ((mdev->dev->caps.tunnel_offload_mode == MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)) {
> > +	    (mdev->dev->caps.tunnel_offload_mode ==  MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)) {
> > +	if ((mdev->dev->caps.tunnel_offload_mode == MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)) {
> 
> Way too many parenthesis, this isn't LISP :-)

Is patchwork stuttering?
I don't see that in the patch I see.

@@ -2400,6 +2478,13 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
        if (mdev->dev->caps.steering_mode != MLX4_STEERING_MODE_A0)
                dev->priv_flags |= IFF_UNICAST_FLT;
 
+       if ((mdev->dev->caps.tunnel_offload_mode == MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)) {
+               dev->hw_enc_features |= NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
+                                       NETIF_F_TSO | NETIF_F_GSO_UDP_TUNNEL;
+               dev->hw_features |= NETIF_F_GSO_UDP_TUNNEL;
+               dev->features    |= NETIF_F_GSO_UDP_TUNNEL;
+       }
