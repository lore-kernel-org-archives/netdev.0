From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] gre: copy ToS/DiffServ bits to outer IP header
Date: Wed, 01 Jul 2009 12:28:27 +0200
Message-ID: <4A4B3A4B.9000502@trash.net>
References: <4A48BC82.6040801@open.ch> <4A48C643.5030709@trash.net> <4A49D55A.4050600@open.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, davem@davemloft.net,
	linux-kernel@vger.kernel.org, shemminger@osdl.org
To: Andreas Jaggi <aj@open.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54592 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751852AbZGAK2e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2009 06:28:34 -0400
In-Reply-To: <4A49D55A.4050600@open.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andreas Jaggi wrote:
> Now using the rtnl_link interface.

Your patches are seriously whitespace-damaged. Please make sure
to send them properly (test by sending to yourself first).

> diff -urN vanilla-linux-2.6.29.4/include/linux/if_tunnel.h 
> dev-gre/include/linux/if_tunnel.h
> --- vanilla-linux-2.6.29.4/include/linux/if_tunnel.h    2009-05-19 
> 01:52:34.000000000 +0200
> +++ dev-gre/include/linux/if_tunnel.h    2009-06-30 08:22:52.000000000 
> +0200
> @@ -34,6 +34,7 @@
>     __be32            i_key;
>     __be32            o_key;
>     struct iphdr        iph;
> +    __u8            copy_tos;

You can't change this structure, this will break compatibility.

> };
> 
> /* SIT-mode i_flags */
> @@ -63,6 +64,7 @@
>     IFLA_GRE_REMOTE,
>     IFLA_GRE_TTL,
>     IFLA_GRE_TOS,
> +    IFLA_GRE_COPY_TOS,
>     IFLA_GRE_PMTUDISC,
>     __IFLA_GRE_MAX,

You can't add new attributes in the middle, they need to be added at
the end.
