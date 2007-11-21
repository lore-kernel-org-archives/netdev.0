From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH][IPVS] Fix compiler warning about unused register_ip_vs_protocol
Date: Wed, 21 Nov 2007 10:38:02 +0900
Message-ID: <20071121013801.GB11665@verge.net.au>
References: <4742CE4A.2000102@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:45934 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756463AbXKUBiI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Nov 2007 20:38:08 -0500
Content-Disposition: inline
In-Reply-To: <4742CE4A.2000102@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 20, 2007 at 03:08:42PM +0300, Pavel Emelyanov wrote:
> This is silly, but I have turned the CONFIG_IP_VS to m,
> to check the compilation of one (recently sent) fix
> and set all the CONFIG_IP_VS_PROTO_XXX options to n to
> speed up the compilation.
> 
> In this configuration the compiler warns me about
> 
>   CC [M]  net/ipv4/ipvs/ip_vs_proto.o
> net/ipv4/ipvs/ip_vs_proto.c:49: warning: ‘register_ip_vs_protocol’ defined but not used
> 
> Indeed. With no protocols selected there are no
> calls to this function - all are compiled out with
> ifdefs.
> 
> Maybe the best fix would be to surround this call with
> ifdef-s or tune the Kconfig dependences, but I think that
> marking this register function as __used is enough. No?
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

That is kind of interesting.

On the one hand it might be more correct in some way to use some Kconfig
foo to get rid of register_ip_vs_protocol, and also most of
the body of ‘register_ip_vs_protocol() if no protocols are defined.

But on the other hand, its really a corner case, because in practice if
you are going to use IPVS then you are going to need at least one
protocol. So I'm happy with the simplicity of the __used solution, even
though strictly speaking it is a lie.

Acked-by: Simon Horman <horms@verge.net.au>

> 
> ---
> 
> diff --git a/net/ipv4/ipvs/ip_vs_proto.c b/net/ipv4/ipvs/ip_vs_proto.c
> index e844ddb..c0e11ec 100644
> --- a/net/ipv4/ipvs/ip_vs_proto.c
> +++ b/net/ipv4/ipvs/ip_vs_proto.c
> @@ -45,7 +45,7 @@ static struct ip_vs_protocol *ip_vs_proto_table[IP_VS_PROTO_TAB_SIZE];
>  /*
>   *	register an ipvs protocol
>   */
> -static int register_ip_vs_protocol(struct ip_vs_protocol *pp)
> +static int __used register_ip_vs_protocol(struct ip_vs_protocol *pp)
>  {
>  	unsigned hash = IP_VS_PROTO_HASH(pp->protocol);
>  
> -- 
> 1.5.3.4
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Horms

