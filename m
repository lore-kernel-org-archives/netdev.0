From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 3/3] iproute2: Add support for phys_port_name
Date: Tue, 24 Mar 2015 15:50:15 -0700
Message-ID: <20150324155015.2dae6252@urahara>
References: <1426520818-11198-1-git-send-email-dsahern@gmail.com>
	<1426520818-11198-3-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34031 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752099AbbCXWuM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 18:50:12 -0400
Received: by pacwe9 with SMTP id we9so7642886pac.1
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 15:50:12 -0700 (PDT)
In-Reply-To: <1426520818-11198-3-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 16 Mar 2015 09:46:58 -0600
David Ahern <dsahern@gmail.com> wrote:

> Display phys_port_name attribute if returned:
> 
> ./ip link show sw1p1
> 4: sw1p1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop port name sw1p1 state DOWN mode DEFAULT group default qlen 1000
>     link/ether 52:54:00:12:35:01 brd ff:ff:ff:ff:ff:ff
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>
> ---
>  include/linux/if_link.h | 1 +
>  ip/ipaddress.c          | 3 +++
>  2 files changed, 4 insertions(+)
> 
> diff --git a/include/linux/if_link.h b/include/linux/if_link.h
> index 3450c3fbdc65..c5ee8c91b1c6 100644
> --- a/include/linux/if_link.h
> +++ b/include/linux/if_link.h
> @@ -147,6 +147,7 @@ enum {
>  	IFLA_CARRIER_CHANGES,
>  	IFLA_PHYS_SWITCH_ID,
>  	IFLA_LINK_NETNSID,
> +	IFLA_PHYS_PORT_NAME,
>  	__IFLA_MAX
>  };
>  
> diff --git a/ip/ipaddress.c b/ip/ipaddress.c
> index 99a6ab5977e3..9e65015b7a48 100644
> --- a/ip/ipaddress.c
> +++ b/ip/ipaddress.c
> @@ -645,6 +645,9 @@ int print_linkinfo(const struct sockaddr_nl *who,
>  				      b1, sizeof(b1)));
>  	}
>  
> +	if (tb[IFLA_PHYS_PORT_NAME])
> +		fprintf(fp, "port name %s ", rta_getattr_str(tb[IFLA_PHYS_PORT_NAME]));
> +
>  	if (tb[IFLA_OPERSTATE])
>  		print_operstate(fp, rta_getattr_u8(tb[IFLA_OPERSTATE]));
>  

In general, this is a good idea, but there are several of issues.
1. There are programs that parse ip route output, therefore all new
   fields need to go at the end.
2. The two word format 'port name' does not match other parts
3. Extra stuff usually goes int 'details' section
4. There are VPN scripts etc that expect all ip commands to
   be invertable. I.e the output of ip link should also be easily
   convertable to input.
