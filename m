From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 06/10] net/mlx4_core: Fix struct mlx4_vhcr_cmd
 to make implicit padding explicit
Date: Tue, 27 Jan 2015 11:13:34 -0800 (PST)
Message-ID: <20150127.111334.501141232585900738.davem@davemloft.net>
References: <1422351179-27284-1-git-send-email-amirv@mellanox.com>
	<1422351179-27284-7-git-send-email-amirv@mellanox.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CAD3B01@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amirv@mellanox.com, netdev@vger.kernel.org, ogerlitz@mellanox.com,
	yevgenyp@mellanox.com, jackm@dev.mellanox.co.il
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52133 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932557AbbA0TNg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 14:13:36 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAD3B01@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Laight <David.Laight@ACULAB.COM>
Date: Tue, 27 Jan 2015 09:43:27 +0000

>>  	__be64 out_param;
>>  	__be16 token;
>>  	u16 reserved;
>>  	u8 status;
>>  	u8 flags;
>>  	__be16 opcode;
>> -};
>> +} __packed;
> 
> Don't add '__packed' unless you expect the structure to be misaligned
> in memory.
> On systems that fault mis-aligned memory requests you've requested the
> compiler generate code to read/write everything using byte sized memory
> accesses and a lot of shifting and masking.

Indeed, I'm really sick of seeing these packed structures being
created all over the place.

They are to be used in absolutely extreme cases where no other
solution is possible.
