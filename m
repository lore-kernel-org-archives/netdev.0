From: Alexey Dobriyan <adobriyan@sw.ru>
Subject: Re: [Devel] [PATCH 1/5] Cut off br_port fied from net_device
Date: Mon, 22 Oct 2007 16:49:15 +0400
Message-ID: <20071022124915.GD6271@localhost.sw.ru>
References: <471C9830.5070407@openvz.org> <471C989D.9030207@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:46298 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751662AbXJVMta (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2007 08:49:30 -0400
Content-Disposition: inline
In-Reply-To: <471C989D.9030207@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 22, 2007 at 04:33:33PM +0400, Pavel Emelyanov wrote:
> And add the forward declaration for br_handle_frame_hook in
> include/linux/if_bridge.h

> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -699,8 +699,10 @@ struct net_device
>  	/* Network namespace this network device is inside */
>  	struct net		*nd_net;
>  
> +#if defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE)
>  	/* bridge stuff */
>  	struct net_bridge_port	*br_port;
> +#endif

Such ifdefs are troublesome, because one can compile kernel with
CONFIG_BRIDGE=n and later decide he needs BRIDGE=m and go boom.

IPv6 -- the biggest violator of this rule should not be taken as
example. :^)

