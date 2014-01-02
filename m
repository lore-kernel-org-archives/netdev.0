From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v2] IPv6: add option to use Subnet-Router anycast addresses as source addresses
Date: Thu, 2 Jan 2014 18:17:31 +0100
Message-ID: <20140102171731.GE22494@order.stressinduktion.org>
References: <1388678028-15413-1-git-send-email-fx.lebail@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:35527 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752490AbaABRRc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 12:17:32 -0500
Content-Disposition: inline
In-Reply-To: <1388678028-15413-1-git-send-email-fx.lebail@yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 02, 2014 at 04:53:48PM +0100, Francois-Xavier Le Bail wrote:
> This change allows to follow a recommandation of RFC4942.
> 
> - Add "enable_anycast_src" sysctl to control the use of Subnet-Router anycast
>   addresses as source addresses. This sysctl is false by default to preserve
>   existing behavior.
> - Use it in ip6_datagram_send_ctl() and icmpv6_echo_reply().

It is very cool that you are working on this. I had this on my TODO list for a
long time.

> Reference:
> RFC4942 - IPv6 Transition/Coexistence Security Considerations
>    (http://tools.ietf.org/html/rfc4942#section-2.1.6)
> 
> 2.1.6. Anycast Traffic Identification and Security
> 
>    [...]
>    To avoid exposing knowledge about the internal structure of the
>    network, it is recommended that anycast servers now take advantage of
>    the ability to return responses with the anycast address as the
>    source address if possible.

Actually, the restriction was lifted by RFC 4291 ("IP Version 6 Addressing
Architecture").


> Signed-off-by: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
> ---
>  Documentation/networking/ip-sysctl.txt |    6 ++++++
>  include/net/netns/ipv6.h               |    1 +
>  net/ipv6/datagram.c                    |    3 +++
>  net/ipv6/icmp.c                        |    4 +++-
>  net/ipv6/sysctl_net_ipv6.c             |    8 ++++++++
>  5 files changed, 21 insertions(+), 1 deletion(-)
> 
> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
> index d71afa8..2a062a7 100644
> --- a/Documentation/networking/ip-sysctl.txt
> +++ b/Documentation/networking/ip-sysctl.txt
> @@ -1094,6 +1094,12 @@ bindv6only - BOOLEAN
>  
>  	Default: FALSE (as specified in RFC3493)
>  
> +enable_anycast_src - BOOLEAN
> +	Controls the use of Subnet-Router anycast addresses as source addresses
> +	TRUE:  enabled
> +	FALSE: disabled
> +	Default: FALSE
> +

I wouldn't actually add this knob, we can just enable that by default.
Also it should be no problem to bind() to those addresses.

I am still unsure what to do with a bind to any or if the address must be
bound specifically (maybe that is worth a knob).

In the long term I would like to see that we can add additional anycast
addresses via iproute:

ip -6 a a 1234::1/64 dev eth0 anycast

or something like that. That should be rather easy, as in just incrementing
the anycast counter for an interface in inet6_rtm_newaddr and adding a flag
to ifa_flags which gets passed down by iproute2.

I'll do some research on if this should also get integrated with source
address selection.

Thanks very much, that is really cool,

  Hannes
