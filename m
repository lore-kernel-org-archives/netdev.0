From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] af_mpls: fix undefined reference to
 ip6_route_output
Date: Wed, 22 Jul 2015 13:04:44 -0700 (PDT)
Message-ID: <20150722.130444.1245167673786115378.davem@davemloft.net>
References: <20150722.104926.1502608671575195516.davem@davemloft.net>
	<55AFEF4B.6070702@cumulusnetworks.com>
	<20150722195706.GA26717@pox.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44616 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779AbbGVUEo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 16:04:44 -0400
In-Reply-To: <20150722195706.GA26717@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Wed, 22 Jul 2015 21:57:06 +0200

> On 07/22/15 at 12:30pm, roopa wrote:
>> diff --git a/net/mpls/Kconfig b/net/mpls/Kconfig
>> index 5c467ef..2b28615 100644
>> --- a/net/mpls/Kconfig
>> +++ b/net/mpls/Kconfig
>> @@ -24,6 +24,8 @@ config NET_MPLS_GSO
>> 
>>  config MPLS_ROUTING
>>         tristate "MPLS: routing support"
>> +       depends on INET
>> +       depends on IPV6
>>         ---help---
>>          Add support for forwarding of mpls packets.
> 
> This looks like a much better fix to me and resolves the
> module/built-in dependency mess.

It's only OK if we don't create a new hard dependency on IPV6,
which this patch does.

Consitently across the tree we give the user the option of
using a bi-AF facility with or without IPV6.
