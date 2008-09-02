From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCHv2 RFC 16/25] IPVS: Add/adjust Netfilter hook functions and helpers for v6
Date: Tue, 2 Sep 2008 15:34:20 +0200
Message-ID: <f4845fc0809020634l7e19f6abn7892bcb9cf12fee2@mail.gmail.com>
References: <1220273782-19901-1-git-send-email-juliusv@google.com>
	 <1220273782-19901-17-git-send-email-juliusv@google.com>
	 <20080902074049.GH13730@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net,
	vbusam@google.com
To: "Simon Horman" <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:16521 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751090AbYIBNea (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2008 09:34:30 -0400
Received: from zps35.corp.google.com (zps35.corp.google.com [172.25.146.35])
	by smtp-out.google.com with ESMTP id m82DYMca015871
	for <netdev@vger.kernel.org>; Tue, 2 Sep 2008 14:34:23 +0100
Received: from nf-out-0910.google.com (nfcd3.prod.google.com [10.48.105.3])
	by zps35.corp.google.com with ESMTP id m82DXtAW003760
	for <netdev@vger.kernel.org>; Tue, 2 Sep 2008 06:34:21 -0700
Received: by nf-out-0910.google.com with SMTP id d3so367104nfc.36
        for <netdev@vger.kernel.org>; Tue, 02 Sep 2008 06:34:21 -0700 (PDT)
In-Reply-To: <20080902074049.GH13730@verge.net.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 2, 2008 at 9:40 AM, Simon Horman <horms@verge.net.au> wrote:
> On Mon, Sep 01, 2008 at 02:56:13PM +0200, Julius Volz wrote:
>> Add Netfilter hook functions or modify existing ones, if possible, to
>> process IPv6 packets. Some support functions are also added/modified for
>> this. ip_vs_nat_icmp_v6() was already added in the patch that added the v6
>> xmit functions, as it is called from one of them.
>>
>> Signed-off-by: Julius Volz <juliusv@google.com>
>
> Please run checkpatch.pl over this patch.
>
>>  1 files changed, 326 insertions(+), 36 deletions(-)
>>
>> diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
>> index 8bfd7c2..0bf871c 100644
>> --- a/net/ipv4/ipvs/ip_vs_core.c
>> +++ b/net/ipv4/ipvs/ip_vs_core.c
>> @@ -39,6 +39,11 @@
>>  #include <linux/netfilter.h>
>>  #include <linux/netfilter_ipv4.h>
>>
>> +#ifdef CONFIG_IP_VS_IPV6
>> +#include <net/ipv6.h>
>> +#include <linux/netfilter_ipv6.h>
>> +#endif
>> +
>>  #include <net/ip_vs.h>
>>
>>
>> @@ -60,6 +65,7 @@ EXPORT_SYMBOL(ip_vs_get_debug_level);
>>
>>  /* ID used in ICMP lookups */
>>  #define icmp_id(icmph)          (((icmph)->un).echo.id)
>> +#define icmpv6_id(icmph)        (icmph->icmp6_dataun.u_echo.identifier)
>
> Should this be ((icmph)->icmp6_dataun.u_echo.identifier) ?

Ah yeah, that is safer, thanks!

-- 
Julius Volz - Corporate Operations - SysOps

Google Switzerland GmbH - Identification No.: CH-020.4.028.116-1
