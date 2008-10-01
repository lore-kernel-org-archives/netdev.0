From: Brian Haley <brian.haley@hp.com>
Subject: Re: [RFC] bonding: add better ipv6 failover support
Date: Wed, 01 Oct 2008 09:24:08 -0400
Message-ID: <48E379F8.7090403@hp.com>
References: <200809151335.16817.asid@hp.com> <20080915180015.GB1078@havoc.gtf.org> <200809151416.49447.alexandre.sidorenko@hp.com> <48DA71A8.5050900@hp.com> <7958.1222288188@death.nxdomain.ibm.com> <48DAFB92.7040904@hp.com> <17219.1222355242@death.nxdomain.ibm.com> <48DBB181.9050205@hp.com> <20081001055355.GA27304@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	Alex Sidorenko <alexandre.sidorenko@hp.com>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:6379 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753174AbYJANYN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 09:24:13 -0400
In-Reply-To: <20081001055355.GA27304@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Simon,

Simon Horman wrote:
> I took a bit of a stab at this, and here is what I cam up with.
> 
> It should enable IPV6_BONDING if one of the following is true
>   * EXPERIMENTAL=y && IPV6=m && BONDING=m
>   * EXPERIMENTAL=y && IPV6=y && BONDING=m
>   * EXPERIMENTAL=y && IPV6=y && BONDING=y
> And disable IPV6_BONDING in all other cases.
> 
> Compile tested only.
> 
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index 69c81da..60c06f8 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -61,6 +61,7 @@ config DUMMY
>  config BONDING
>  	tristate "Bonding driver support"
>  	depends on INET
> +	select IPV6_BONDING if (IPV6=y || IPV6=BONDING) && EXPERIMENTAL
>  	---help---
>  	  Say 'Y' or 'M' if you wish to be able to 'bond' multiple Ethernet
>  	  Channels together. This is called 'Etherchannel' by Cisco,
> diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
> index ec99215..49108be 100644
> --- a/net/ipv6/Kconfig
> +++ b/net/ipv6/Kconfig
> @@ -217,4 +217,7 @@ config IPV6_PIMSM_V2
>  	  Support for IPv6 PIM multicast routing protocol PIM-SMv2.
>  	  If unsure, say N.
>  
> +config IPV6_BONDING
> +	bool
> +
>  endif # IPV6

I actually figured out how to do this without having a new Kconfig 
option at all, and building bonding_ipv6.c without getting a linker 
error.  I'll send out an updated patch soon, just sorting out the vlan 
support right now.

Thanks,

-Brian
