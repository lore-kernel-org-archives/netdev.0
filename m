From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH][RESEND] IPv6: 6rd tunnel mode
Date: Mon, 21 Sep 2009 22:39:45 -0400
Message-ID: <4AB838F1.1090704@hp.com>
References: <20090922003956.GA19947@lnxos.staff.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alexandre Cassen <acassen@freebox.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:12097 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751576AbZIVCjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2009 22:39:43 -0400
In-Reply-To: <20090922003956.GA19947@lnxos.staff.proxad.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alexandre,

Alexandre Cassen wrote:
> This patch add support to 6rd tunnel mode currently targetting
> standard track at the IETF.
> 
> IPv6 rapid deployment (RFC5569) builds upon mechanisms of 6to4 (RFC3056)
> to enable a service provider to rapidly deploy IPv6 unicast service
> to IPv4 sites to which it provides customer premise equipment.  Like
> 6to4, it utilizes stateless IPv6 in IPv4 encapsulation in order to
> transit IPv4-only network infrastructure. Unlike 6to4, a 6rd service
> provider uses an IPv6 prefix of its own in place of the fixed 6to4
> prefix.

I couldn't find RFC 5569 (delayed due to IPR rights?), although I did find
the latest 6rd draft, -03.  It was showing as Informational, not Standards
track, is that right?  Just curious.

> +		case SIOCADD6RD:
> +		case SIOCCHG6RD:
> +			if (ip6rd.prefixlen >= 95) {
> +				err = -EINVAL;
> +				goto done;
> +			}
> +			t->ip6rd_prefix.addr = ip6rd.addr;

ipv6_addr_copy(&t->ip6rd_prefix.addr, &ip6rd.addr); is the preferred way to
copy the address.

-Brian
