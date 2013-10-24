From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch net-next] ipv6: allow userspace to create address with IFLA_F_TEMPORARY flag
Date: Thu, 24 Oct 2013 16:02:53 +0200
Message-ID: <20131024140253.GF15744@order.stressinduktion.org>
References: <1382622355-6500-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	thaller@redhat.com, stephen@networkplumber.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:55018 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755070Ab3JXOCz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 10:02:55 -0400
Content-Disposition: inline
In-Reply-To: <1382622355-6500-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 24, 2013 at 03:45:55PM +0200, Jiri Pirko wrote:
> This is needed in order to implement userspace address configuration,
> namely ip6-privacy (rfc4941) in NetworkManager.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  net/ipv6/addrconf.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index cd3fb30..962c7c9 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -3715,7 +3715,8 @@ inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
>  		return -ENODEV;
>  
>  	/* We ignore other flags so far. */
> -	ifa_flags = ifm->ifa_flags & (IFA_F_NODAD | IFA_F_HOMEADDRESS);
> +	ifa_flags = ifm->ifa_flags & (IFA_F_NODAD | IFA_F_HOMEADDRESS |
> +				      IFA_F_TEMPORARY);
>  
>  	ifa = ipv6_get_ifaddr(net, pfx, dev, 1);
>  	if (ifa == NULL) {

Hm, the kernel will pick up IFA_F_TEMPORARY marked addresses and do ipv6 address
regeneration (depending on lifetimes). Is this intended?

Btw. I am very interested in this topic as there is currently work in the IETF
to move away from eui-48 generation of addresses:

https://datatracker.ietf.org/doc/draft-ietf-6man-stable-privacy-addresses/

This needs to be done in userspace as we depend on a secret generated at
system install time.

Greetings,

  Hannes
