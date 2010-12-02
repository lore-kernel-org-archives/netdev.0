From: Thomas Graf <tgraf@infradead.org>
Subject: Re: [PATCH v2 1/4] net: snmp: fix the wrong ICMP_MIB_MAX value
Date: Thu, 2 Dec 2010 04:57:53 -0500
Message-ID: <20101202095753.GA10221@canuck.infradead.org>
References: <4CF71ADB.5060702@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Network-Maillist <netdev@vger.kernel.org>
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([134.117.69.58]:37208 "EHLO
	canuck.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752459Ab0LBJ57 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 04:57:59 -0500
Content-Disposition: inline
In-Reply-To: <4CF71ADB.5060702@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 02, 2010 at 12:04:43PM +0800, Shan Wei wrote:
> __ICMP_MIB_MAX is equal to the total number of icmp mib,
> So no need to add 1. This wastes 4/8 bytes memory.
> 
> Change it to be same as ICMP6_MIB_MAX, TCP_MIB_MAX, UDP_MIB_MAX.
> 
> 
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
> ---
>  include/net/snmp.h |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/include/net/snmp.h b/include/net/snmp.h
> index a0e6180..aebb553 100644
> --- a/include/net/snmp.h
> +++ b/include/net/snmp.h
> @@ -61,8 +61,7 @@ struct ipstats_mib {
>  
>  /* ICMP */
>  #define ICMP_MIB_DUMMY	__ICMP_MIB_MAX
> -#define ICMP_MIB_MAX	(__ICMP_MIB_MAX + 1)
> -
> +#define ICMP_MIB_MAX	__ICMP_MIB_MAX

Looks like the +1 is there to account for ICMP_MIB_DUMMY. It is
unused though but you have to remove it as well if you want to
kill that extra +1.
