From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Subject: Re: [PATCH RFC] ipv6: stable privacy addresses
Date: Fri, 13 Dec 2013 11:33:23 +0100
Message-ID: <52AAE273.7070806@enst-bretagne.fr>
References: <20131213085549.GA3685@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fgont@si6networks.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fourcot.fr ([217.70.191.14]:48155 "EHLO olfflo.fourcot.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752582Ab3LMKd1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Dec 2013 05:33:27 -0500
In-Reply-To: <20131213085549.GA3685@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> This is a preview for the interface I envison for IPv6 stable privacy
> addresses.


Great!

> +stable_address_secret - UNSIGNED LONG
> +	If stable privacy addresses are enabled then on the first
> +	write to this file link-local addresses are generated and
> +	router solicitions are send out. The generated addresses are

s/solicitions/solicitations/

> +	based on this secret.  If the same secret is reused across
> +	reboots the generated addresses will be the same.
> +

Do you not provide a configuration via netlink for the secret?


> +idgen_delay - INTEGER
> +	Seconds to delay another attempt to generate a stable privacy address.

Perhaps s/Seconds/Milliseconds/ ?



> +config IPV6_ADDRESS_GEN_MODE_STABLE_PRIVACY_V1
> +       bool "Stable privacy address generation v1"
> +       help
> +         Stable privacy address generation mode v1. Further
> +         information can be found here:
> +	 http://tools.ietf.org/html/draft-ietf-6man-stable-privacy-addresses-16
> +
> +	 This option may need support from distributions to install
> +	 the stable secret early at boot up (otherwise link-local
> +	 addresses will be generated too late). If you don't have
> +	 services depending on link-local addresses on boot-up you can
> +	 activate this mode and install the stable secret any time
> +	 later by hand by writing it to
> +	 /proc/sys/net/ipv6/stable_privacy_secret.
> +

Here is your documentation inconsistent with before. The right file is
probably /proc/sys/net/ipv6/stable_address_secret

You configuration is for all interfaces the same, isn't? I would like a
configuration possibility per interface, to mix EUI64 and stable privacy
addresses on the same device.

In the same way, the configuration of the secret per interface could be
useful (simple example: two NIC on the same LAN).


> -static void addrconf_dad_stop(struct inet6_ifaddr *ifp, int dad_failed)
> +static void addrconf_dad_stop(struct inet6_ifaddr *ifp, bool dad_failed)
> 

The passage of dad_failed from int to bool is not directly connected
with this feature, can you maybe split it in another patch?


Florent.
