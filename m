From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net] net/mlx4_core: Limit count field to 24 bits in qp_alloc_res
Date: Wed, 26 Nov 2014 16:20:13 +0200
Message-ID: <5475E19D.5000508@mellanox.com>
References: <1416909271-28840-1-git-send-email-ogerlitz@mellanox.com>
 <20141125.141620.1331667846639491375.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <matanb@mellanox.com>,
	<amirv@mellanox.com>, <jackm@dev.mellanox.co.il>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0085.outbound.protection.outlook.com ([157.55.234.85]:42528
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752998AbaKZOjz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Nov 2014 09:39:55 -0500
In-Reply-To: <20141125.141620.1331667846639491375.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/25/2014 9:16 PM, David Miller wrote:
> From: Or Gerlitz <ogerlitz@mellanox.com>
> Date: Tue, 25 Nov 2014 11:54:31 +0200
>
>>   	case RES_OP_RESERVE:
>> -		count = get_param_l(&in_param);
>> +		count = get_param_l(&in_param) & 0xffffff;
> I think if these high bits are set, you should be using the maximum
> value rather then truncating.

Dave,

To make it clear (maybe the change-log wasn't explaining it well 
enough), the 32 bits in_param are
divided to 24 bits of count and 8 bits for optimized allocation scheme 
which isn't yet supported
by the Linux PF driver.

Currently, the upstream PF driver is wrongly NOT masking out these eight 
bits and as such, some
VF drivers which are already setting them for optimized allocation are 
failing to allocate QPs as
the count seen by the PF becomes way too large.  The optimization is 
best effort anyway, and hence
we can safely ignore their request.

If we follow your suggestion and allocate to these VFs per the maximum 
number, we will
hit their quota after they open one QP and their over-all bring up will 
fail, so this will not help.

Or.
