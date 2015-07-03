From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH net-next] ipv6: sysctl to restrict candidate source addresses
Date: Fri, 03 Jul 2015 16:03:02 +0900
Message-ID: <559633A6.9040403@miraclelinux.com>
References: <1435898941-9259-1-git-send-email-ek@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com, lorenzo@google.com,
	netdev@vger.kernel.org, davem@davemloft.net
To: Erik Kline <ek@google.com>, hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:35947 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754420AbbGCHDG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2015 03:03:06 -0400
Received: by pdcu2 with SMTP id u2so59810264pdc.3
        for <netdev@vger.kernel.org>; Fri, 03 Jul 2015 00:03:05 -0700 (PDT)
In-Reply-To: <1435898941-9259-1-git-send-email-ek@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Erik Kline wrote:
> Per RFC 6724, section 4, "Candidate Source Addresses":
> 
>     It is RECOMMENDED that the candidate source addresses be the set
>     of unicast addresses assigned to the interface that will be used
>     to send to the destination (the "outgoing" interface).
> 
> Add a sysctl to enable this behaviour.
> 
> Signed-off-by: Erik Kline <ek@google.com>
> ---
>  Documentation/networking/ip-sysctl.txt | 12 ++++++++++++
>  include/linux/ipv6.h                   |  1 +
>  include/uapi/linux/ipv6.h              |  1 +
>  net/ipv6/addrconf.c                    | 30 +++++++++++++++++++++++++-----
>  4 files changed, 39 insertions(+), 5 deletions(-)
> 
> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
> index 5fae770..d8f3e60 100644
> --- a/Documentation/networking/ip-sysctl.txt
> +++ b/Documentation/networking/ip-sysctl.txt
> @@ -1435,6 +1435,18 @@ mtu - INTEGER
>  	Default Maximum Transfer Unit
>  	Default: 1280 (IPv6 required minimum)
>  
> +restrict_srcaddr - INTEGER
> +	Restrict candidate source addresses (vis. RFC 6724, section 4).
> +
> +	When set to 1, the candidate source addresses for destinations
> +	routed via this interface are restricted to the set of addresses
> +	configured on this interface.
> +
> +	Possible values are:
> +		0 : no source address restrictions
> +		1 : require matching outgoing interface
> +	Default:  0
> +

I cannot get what "restrict" restricts.  How about "use_oif_addr" or
something like that (like use_tempaddr)?

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
