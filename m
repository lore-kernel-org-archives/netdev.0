From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: Re: [RESEND 3/5] [NET]: Protocol Independant Policy Routing Rules
 Framework
Date: Mon, 31 Jul 2006 17:46:14 +0300
Message-ID: <44CE17B6.2070108@tcs.hut.fi>
References: <20060726221100.325687073@postel.suug.ch> <20060726221849.807482409@postel.suug.ch> <Pine.LNX.4.64.0607270158001.4779@d.namei> <20060726.230230.111423566.davem@davemloft.net> <20060727223931.GZ14627@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jmorris@namei.org,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from neon.tcs.hut.fi ([130.233.215.20]:64266 "EHLO neon.tcs.hut.fi")
	by vger.kernel.org with ESMTP id S1750994AbWGaOqT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2006 10:46:19 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060727223931.GZ14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:

Hi Thomas,


> Derived from net/ipv6/fib_rules.c

do you mean net/ipv4/fib_rules.c or net/ipv6/fib6_rules.c? :-)

A couple of comments below.

> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> 
> Index: net-2.6.git/include/linux/fib_rules.h
> ===================================================================
> --- /dev/null
> +++ net-2.6.git/include/linux/fib_rules.h
> @@ -0,0 +1,60 @@
> +#ifndef __LINUX_FIB_RULES_H
> +#define __LINUX_FIB_RULES_H
> +
> +#include <linux/types.h>
> +#include <linux/rtnetlink.h>
> +
> +/* rule is permanent, and cannot be deleted */
> +#define FIB_RULE_PERMANENT	1
> +
> +struct fib_rule_hdr
> +{
> +	__u8		family;
> +	__u8		dst_len;
> +	__u8		src_len;
> +	__u8		tos;
> +
> +	__u8		table;
> +	__u8		res1;	/* reserved */
> +	__u8		res2;	/* reserved */
> +	__u8		action;
> +
> +	__u32		flags;
> +};

I'm wondering if this is guaranteed to be equvalent to struct rtmsg?

struct rtmsg
{
	unsigned char		rtm_family;
	unsigned char		rtm_dst_len;
	unsigned char		rtm_src_len;
	unsigned char		rtm_tos;

	unsigned char		rtm_table;	/* Routing table id */
	unsigned char		rtm_protocol;	/* Routing protocol; see below	*/
	unsigned char		rtm_scope;	/* See below */	
	unsigned char		rtm_type;	/* See below	*/

	unsigned		rtm_flags;
};

Won't we otherwise be breaking the existing userland interface?

> +enum
> +{
> +	FRA_UNSPEC,
> +	FRA_DST,	/* destination address */
> +	FRA_SRC,	/* source address */
> +	FRA_IFNAME,	/* interface name */
> +	FRA_UNUSED1,
> +	FRA_UNUSED2,
> +	FRA_PRIORITY,	/* priority/preference */
> +	FRA_UNUSED3,
> +	FRA_UNUSED4,
> +	FRA_UNUSED5,
> +	FRA_FWMARK,	/* netfilter mark (IPv4) */
> +	FRA_FLOW,	/* flow/class id */
> +	__FRA_MAX
> +};
> +
> +#define FRA_MAX (__FRA_MAX - 1)
> +
> +enum
> +{
> +	FR_ACT_UNSPEC,
> +	FR_ACT_TO_TBL,		/* Pass to fixed table */
> +	FR_ACT_RES1,
> +	FR_ACT_RES2,
> +	FR_ACT_RES3,
> +	FR_ACT_RES4,
> +	FR_ACT_BLACKHOLE,	/* Drop without notification */
> +	FR_ACT_UNREACHABLE,	/* Drop with ENETUNREACH */
> +	FR_ACT_PROHIBIT,	/* Drop with EACCES */
> +	__FR_ACT_MAX,
> +};
> +
> +#define FR_ACT_MAX (__FR_ACT_MAX - 1)
> +
> +#endif

Shouldn't all these (struct fib_rule_hdr included) actually be defined
in include/linux/rtnetlink.h?

Otherwise, looks good.

Regards,
Ville
