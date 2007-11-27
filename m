From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH][BRIDGE] Properly dereference the br_should_route_hook
Date: Tue, 27 Nov 2007 08:16:55 -0800
Message-ID: <20071127081655.40474d79@freepuppy.rosehill>
References: <474C41DB.4080007@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, bridge@lists.osdl.org,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:49303 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752372AbXK0QRa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 11:17:30 -0500
In-Reply-To: <474C41DB.4080007@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 27 Nov 2007 19:12:11 +0300
Pavel Emelyanov <xemul@openvz.org> wrote:

> This hook is protected with the RCU, so simple
> 
> 	if (br_should_route_hook)
> 		br_should_route_hook(...)
> 
> is not enough on some architectures.
> 
> Use the rcu_dereference/rcu_assign_pointer in this case.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> ---
> 
> diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
> index 3cedd4e..b42b192 100644
> --- a/net/bridge/br_input.c
> +++ b/net/bridge/br_input.c
> @@ -122,6 +122,7 @@ static inline int is_link_local(const unsigned char *dest)
>  struct sk_buff *br_handle_frame(struct net_bridge_port *p, struct sk_buff *skb)
>  {
>  	const unsigned char *dest = eth_hdr(skb)->h_dest;
> +	typeof(br_should_route_hook) rhook;

Okay, but I don't like the typeof() magic. Resubmit with proper declartion.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
