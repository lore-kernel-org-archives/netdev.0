From: "Robert P. J. Day" <rpjday@mindspring.com>
Subject: Re: [PATCH] IP_VS should depend on EXPERIMENTAL ?
Date: Fri, 20 Jul 2007 07:59:56 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0707200753300.10966@localhost.localdomain>
References: <46A0A01A.7030403@googlemail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Gabriel C <nix.or.die@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nic.NetDirect.CA ([216.16.235.2]:37424 "EHLO
	rubicon.netdirect.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754473AbXGTMBr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2007 08:01:47 -0400
In-Reply-To: <46A0A01A.7030403@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 20 Jul 2007, Gabriel C wrote:

> Hi,
>
> IP_VS has :
>
> ..
>
> tristate "IP virtual server support (EXPERIMENTAL)"
>
> ..
>
> but it does not depend on EXPERIMENTAL.
>
>
> Signed-off-by: Gabriel Craciunescu <nix.or.die@googlemail.com>
>
> ---
>
>  net/ipv4/ipvs/Kconfig |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/net/ipv4/ipvs/Kconfig b/net/ipv4/ipvs/Kconfig
> index 09d0c3f..3c594ec 100644
> --- a/net/ipv4/ipvs/Kconfig
> +++ b/net/ipv4/ipvs/Kconfig
> @@ -3,7 +3,7 @@
>  #
>  menuconfig IP_VS
>  	tristate "IP virtual server support (EXPERIMENTAL)"
> -	depends on NETFILTER
> +	depends on NETFILTER && EXPERIMENTAL
>  	---help---
>  	  IP Virtual Server support will let you build a high-performance
>  	  virtual server based on cluster of two or more real servers. This

there's maturity-level inconsistency like that in a few places, like
when stuff is tagged as EXPERIMENTAL, but labelled as OBSOLETE:

./net/ipv6/netfilter/Kconfig-config IP6_NF_QUEUE
./net/ipv6/netfilter/Kconfig-   tristate "IP6 Userspace queueing via NETLINK (OBSOLETE)"
./net/ipv6/netfilter/Kconfig:   depends on INET && IPV6 && NETFILTER && EXPERIMENTAL

and other examples:

./net/ipv6/netfilter/Kconfig-config IP6_NF_IPTABLES
./net/ipv6/netfilter/Kconfig-   tristate "IP6 tables support (required for filtering)"
./net/ipv6/netfilter/Kconfig:   depends on INET && IPV6 && EXPERIMENTAL
...
./net/ipv6/Kconfig-config IPV6_MULTIPLE_TABLES
./net/ipv6/Kconfig-     bool "IPv6: Multiple Routing Tables"
./net/ipv6/Kconfig:     depends on IPV6 && EXPERIMENTAL
...
./net/ipv4/Kconfig-config TCP_CONG_HSTCP
./net/ipv4/Kconfig-     tristate "High Speed TCP"
./net/ipv4/Kconfig:     depends on EXPERIMENTAL
...
./net/rxrpc/Kconfig-config AF_RXRPC
./net/rxrpc/Kconfig-    tristate "RxRPC session sockets"
./net/rxrpc/Kconfig:    depends on INET && EXPERIMENTAL
...

  it might be a better investment in time to look through the Kconfig
files, and decide which entries currently marked as "EXPERIMENTAL"
really *shouldn't* be, and remove those silly dependencies.

rday
-- 
========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry
Waterloo, Ontario, CANADA

http://fsdev.net/wiki/index.php?title=Main_Page
========================================================================
