From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch 3/4] Make sure ip_vs_ftp ports are valid
Date: Mon, 04 Sep 2006 01:09:59 +0200
Message-ID: <44FB60C7.30300@trash.net>
References: <20060901101036.181146000@tabatha.lab.ultramonkey.org> <20060901101756.637601000@tabatha.lab.ultramonkey.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>,
	Julian Anastasov <ja@ssi.bg>,
	David Miller <davem@davemloft.net>,
	Joseph Mack NA3T <jmack@wm7d.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44970 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S932116AbWICXMp
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Sep 2006 19:12:45 -0400
To: Horms <horms@verge.net.au>
In-Reply-To: <20060901101756.637601000@tabatha.lab.ultramonkey.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Horms wrote:
> I'm not entirely sure what happens in the case of a valid port,
> at best it'll be silently ignored. This patch ignores them a little
> more verbosely.
> 
> Signed-Off-By: Simon Horman <horms@verge.net.au>
> Index: linux-2.6/net/ipv4/ipvs/ip_vs_ftp.c
> ===================================================================
> --- linux-2.6.orig/net/ipv4/ipvs/ip_vs_ftp.c	2006-09-01 19:06:42.000000000 +0900
> +++ linux-2.6/net/ipv4/ipvs/ip_vs_ftp.c	2006-09-01 19:08:19.000000000 +0900
> @@ -373,6 +373,12 @@
>  	for (i=0; i<IP_VS_APP_MAX_PORTS; i++) {
>  		if (!ports[i])
>  			continue;
> +		if (ports[i] < 0 || ports[i] > 0xffff) {
> +			IP_VS_WARNING("ip_vs_ftp: Ignoring invalid "
> +				      "configuration port[%d] = %d\n",
> +				      i, ports[i]);
> +			continue;
> +		}

How about just changing the module parameter type to ushort, similar to
what ip_conntrack_ftp does?

# modprobe ip_conntrack_ftp ports=999392
ip_conntrack_ftp: `999392' invalid for parameter `ports'


-- 
VGER BF report: H 0.41558
