From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH 5/5] introduce udp_rmem and udp_wmem
Date: Tue, 30 Oct 2007 00:52:48 -0400
Message-ID: <20071030005248.b0e6e9d2.billfink@mindspring.com>
References: <47264E2D.4080109@redhat.com>
	<47264F5F.6040905@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Andi Kleen <andi@firstfloor.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>
To: Hideo AOKI <haoki@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-mealy.atl.sa.earthlink.net ([209.86.89.69]:58395 "EHLO
	elasmtp-mealy.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752664AbXJ3ExJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2007 00:53:09 -0400
In-Reply-To: <47264F5F.6040905@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 29 Oct 2007, Hideo AOKI wrote:

> This patch added /proc/sys/net/udp_rmem and /proc/sys/net/udp_rmem.
> Each UDP packet is drooped when the number of pages for socket buffer
> is beyond the limit and the socket already consumes minimum buffer.

I think you meant /proc/sys/net/ipv4/udp_{r,w}mem above.

Patch not in-lined making replying more difficult.

Cutting and pasting:

> diff -pruN linux-2.6.24-rc1-mem003-ipv4-dev-p4/Documentation/networking/ip-sysctl.txt linux-2.6.24-rc1-mem003-ipv4-dev-p5/Documentation/networking/ip-sysctl.txt
> --- linux-2.6.24-rc1-mem003-ipv4-dev-p4/Documentation/networking/ip-sysctl.txt	2007-10-26 20:35:52.000000000 -0400
> +++ linux-2.6.24-rc1-mem003-ipv4-dev-p5/Documentation/networking/ip-sysctl.txt	2007-10-29 09:44:05.000000000 -0400
> @@ -452,6 +452,18 @@ udp_mem - INTEGER
>  	Number of pages allowed for queueing by all UDP sockets.
>  	Default is calculated at boot time from amount of available memory.
>  
> +udp_rmem - INTEGER
> +	Minimal size of receive buffer used by UDP sockets. Each UDP socket
> +	is able to use the size for receiving data, even if total pages of UDP
> +	sockets exceed udp_mem. The unit is byte.
> +	Default: 4096
> +
> +udp_wmem - INTEGER
> +	Minimal size of send buffer used by UDP sockets. Each UDP socket is
> +	able to use the size for sending data, even if total pages of UDP
> +	sockets exceed udp_mem. The unit is byte.
> +	Default: 4096
> +
>  CIPSOv4 Variables:
>  
>  cipso_cache_enable - BOOLEAN

I think either the above should be renamed to udp_{r,w}mem_min, or
they should be changed to a 3-tuple like tcp_{r,w}mem, and the code
refactored accordingly (but then what to do about
/proc/sys/net/core/{r,w}mem_max).

						-Bill
