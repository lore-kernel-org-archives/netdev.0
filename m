From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH RESEND] 8021q:Add missing statements to switch case in
 the function, register_vlan_device
Date: Mon, 7 Mar 2016 12:29:05 +0100
Message-ID: <20160307112905.GA2378@macbook.localdomain>
References: <1457322689-19443-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49336 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752192AbcCGLhq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 06:37:46 -0500
Content-Disposition: inline
In-Reply-To: <1457322689-19443-1-git-send-email-xerofoify@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06.03, Nicholas Krause wrote:
> This adds the proper snprintf and break statement for formatting
> the vlan_net structure pointer, vn's name using snprintf for if
> the switch case, VLAN_NAME_TYPE_PLUS_VID occurs for this particular
> switch statement inside the function, register_vlan_device.
> 
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---
>  net/8021q/vlan.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
> index 59555f0..91ef50e 100644
> --- a/net/8021q/vlan.c
> +++ b/net/8021q/vlan.c
> @@ -246,8 +246,11 @@ static int register_vlan_device(struct net_device *real_dev, u16 vlan_id)
>  		/* Put our vlan.VID in the name.
>  		 * Name will look like:	 vlan0005
>  		 */
> +		snprintf(name, IFNAMSIZ, "%s%i", real_dev->name, vlan_id);
> +		break;

As the comment indicates, the fall-through is intended like this.

>  	default:
>  		snprintf(name, IFNAMSIZ, "vlan%.4i", vlan_id);
> +		break;
>  	}
>  
>  	new_dev = alloc_netdev(sizeof(struct vlan_dev_priv), name,
> -- 
> 2.1.4
> 
