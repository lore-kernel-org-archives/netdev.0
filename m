From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net] net/vxlan: Use the underlying device index when
 joining/leaving multicast groups
Date: Thu, 20 Dec 2012 08:26:08 -0800
Message-ID: <20121220082608.498b8741@nehalam.linuxnetplumber.net>
References: <1356010568-21644-1-git-send-email-yanb@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com
To: Yan Burman <yanb@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60436 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750956Ab2LTQ1Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2012 11:27:24 -0500
In-Reply-To: <1356010568-21644-1-git-send-email-yanb@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 20 Dec 2012 15:36:08 +0200
Yan Burman <yanb@mellanox.com> wrote:

> The socket calls from vxlan to join/leave multicast group aren't
> using the index of the underlying device, as a result the stack uses
> the first interface that is up. This results in vxlan being non functional
> over a device which isn't the 1st to be up.
> Fix this by providing the iflink field to the vxlan instance
> to the multicast calls.
> 
> Signed-off-by: Yan Burman <yanb@mellanox.com>
> ---
>  drivers/net/vxlan.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 3b3fdf6..40f2cc1 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -505,7 +505,8 @@ static int vxlan_join_group(struct net_device *dev)
>  	struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
>  	struct sock *sk = vn->sock->sk;
>  	struct ip_mreqn mreq = {
> -		.imr_multiaddr.s_addr = vxlan->gaddr,
> +		.imr_multiaddr.s_addr	= vxlan->gaddr,
> +		.imr_ifindex		= vxlan->link,
>  	};
>  	int err;
>  
> @@ -532,7 +533,8 @@ static int vxlan_leave_group(struct net_device *dev)
>  	int err = 0;
>  	struct sock *sk = vn->sock->sk;
>  	struct ip_mreqn mreq = {
> -		.imr_multiaddr.s_addr = vxlan->gaddr,
> +		.imr_multiaddr.s_addr	= vxlan->gaddr,
> +		.imr_ifindex		= vxlan->link,
>  	};
>  
>  	/* Only leave group when last vxlan is done. */

Acked-by: Stephen Hemminger <shemminger@vyatta.com>
