From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] gre: copy ToS/DiffServ bits to outer IP header
Date: Mon, 29 Jun 2009 15:48:51 +0200
Message-ID: <4A48C643.5030709@trash.net>
References: <4A48BC82.6040801@open.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, davem@davemloft.net,
	linux-kernel@vger.kernel.org
To: Andreas Jaggi <aj@open.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37481 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751486AbZF2Nsz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2009 09:48:55 -0400
In-Reply-To: <4A48BC82.6040801@open.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andreas Jaggi wrote:
> When tunneling IP traffic with GRE this patch makes it possible to 
> export the ToS/DiffServ information to the outer IP header.
> This is particularly useful in a scenario with ESP/AH where the inner IP 
> header is encrypted but the packet priority/DiffServ information
> should still be respected by the transporting routers (for example in an 
> MPLS backbone network).
> 
> The feature is disabled by default and can be enabled on a per-interface 
> basis (/proc/sys/net/ipv4/conf/ethX/gre_copy_tos).
> 
> Also does this bring Linux back in the game, as JunOS/IOS provide this 
> for quite some time:
> http://www.cisco.com/en/US/docs/ios/11_3/feature/guide/greqos.html
> http://www.juniper.net/techpubs/software/junos/junos94/swconfig-services/configuring-a-gre-tunnel-to-copy-tos-bits-to-the-outer-ip-header.html 
> 
> 
> Signed-off-by: Andreas Jaggi <aj@open.ch>
> 
> diff -urN vanilla-linux-2.6.29.4/include/linux/sysctl.h 
> gre-copy-tos/include/linux/sysctl.h
> --- vanilla-linux-2.6.29.4/include/linux/sysctl.h    2009-05-19 
> 01:52:34.000000000 +0200
> +++ gre-copy-tos/include/linux/sysctl.h    2009-06-29 14:23:07.000000000 
> +0200
> @@ -490,6 +490,7 @@
>     NET_IPV4_CONF_ARP_IGNORE=19,
>     NET_IPV4_CONF_PROMOTE_SECONDARIES=20,
>     NET_IPV4_CONF_ARP_ACCEPT=21,
> +    NET_IPV4_CONF_GRE_COPY_TOS=22,

Please add this to the rtnl_link interface instead of using
sysctls.
