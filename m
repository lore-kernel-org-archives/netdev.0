From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V1 net-next 2/4] net/mlx5_core: Use hardware registers
 description header file
Date: Wed, 01 Oct 2014 14:56:15 -0400 (EDT)
Message-ID: <20141001.145615.234381013367053243.davem@davemloft.net>
References: <1412169488-17500-1-git-send-email-eli@mellanox.com>
	<1412169488-17500-3-git-send-email-eli@mellanox.com>
	<CAADnVQ+0q=j9soWX-ge6Re4F6sDahq=O-Ptaguca8WUaTE-qQw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eli@mellanox.com, netdev@vger.kernel.org, ogerlitz@mellanox.com,
	yevgenyp@mellanox.com, joe@perches.com
To: alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35334 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751518AbaJAS4T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 14:56:19 -0400
In-Reply-To: <CAADnVQ+0q=j9soWX-ge6Re4F6sDahq=O-Ptaguca8WUaTE-qQw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Wed, 1 Oct 2014 10:12:10 -0700

>> +#define MLX5_SET64(typ, p, fld, v) do { \
>> +       if (__mlx5_bit_sz(typ, fld) != 64) \
>> +               non_existent_function(); \
>> +       else if (__mlx5_bit_off(typ, fld) % 64) \
>> +               non_existent_function(); \
>> +       else \
>> +               *((__be64 *)(p) + __mlx5_64_off(typ, fld)) = cpu_to_be64(v); \
>> +} while (0)
> 
> is it possible to use BUILD_BUG_ON instead of runtime pr_info() ?

Indeed, please don't invent your own facilities for compile-time checks,
we have BUILD_BUG_ON() so please use it instead of non_existent_function()
which BTW doesn't work with some non-gcc compilers.
