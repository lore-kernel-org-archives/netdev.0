From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] tipc: fix undefined __ipv6_sock_mc_join
 compile error
Date: Wed, 11 Mar 2015 17:59:54 -0400 (EDT)
Message-ID: <20150311.175954.948622401089738977.davem@davemloft.net>
References: <1426060274-2930-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, Paul.Gortmaker@windriver.com,
	erik.hugne@ericsson.com, fengguang.wu@intel.com,
	netdev@vger.kernel.org, willemb@google.com,
	tipc-discussion@lists.sourceforge.net, kbuild-all@01.org
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52484 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751699AbbCKV76 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 17:59:58 -0400
In-Reply-To: <1426060274-2930-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>
Date: Wed, 11 Mar 2015 15:51:13 +0800

> diff --git a/net/tipc/Kconfig b/net/tipc/Kconfig
> index c25a3a1..5bb8fc9 100644
> --- a/net/tipc/Kconfig
> +++ b/net/tipc/Kconfig
> @@ -29,6 +29,7 @@ config TIPC_MEDIA_IB
>  config TIPC_MEDIA_UDP
>  	bool "IP/UDP media type support"
>  	depends on TIPC
> +	depends on (IPV6=y || IPV6=n)
>  	select NET_UDP_TUNNEL
>  	help
>  	  Saying Y here will enable support for running TIPC over IP/UDP

This really is not what you want.

You want to enable TIPC_MEDIA_UDP if IPV6 is "compatible" with TIPC,
what you're using here is a sledgehammer.

I would really suggest breaking this facility out into it's own
module, then you can mark it tristate and do this correctly.
