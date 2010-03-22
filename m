From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [RFC] GTSM for IPv6
Date: Mon, 22 Mar 2010 16:27:24 +0900
Message-ID: <4BA71BDC.1080609@linux-ipv6.org>
References: <20100319095640.42c8d82d@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:40302 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753512Ab0CVH1o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 03:27:44 -0400
In-Reply-To: <20100319095640.42c8d82d@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(2010/03/20 1:56), Stephen Hemminger wrote:
> Also RFC doesn't explicitly address GTSM on IPV6.
> Maybe the RFC editors think the problem will magically no longer exist
> in IPv6 world because everyone will be using IPsec.

> ---
>   include/linux/in6.h      |    3 +++
>   include/linux/ipv6.h     |    3 ++-
>   net/ipv6/ipv6_sockglue.c |   12 ++++++++++++
>   net/ipv6/tcp_ipv6.c      |   17 ++++++++++++++---
>   4 files changed, 31 insertions(+), 4 deletions(-)

Why don't we have code for other protocols such as
UDP etc?  We already have similar protection in NDP,
It seem to make sense.

And, as many other socket options (such as IPV6_UNICAST_HOPS
etc.) do, please accept value of -1 to set the system's
default (0 so far).

             x < -1:        return an error of EINVAL
             x == -1:       use kernel default
             0 <= x <= 255: use x
             x >= 256:      return an error of EINVAL

We may also want to have sysctl for it.

Regrads,

--yoshfuji
