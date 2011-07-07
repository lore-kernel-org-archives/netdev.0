From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] lib/checksum.c: optimize do_csum a bit
Date: Thu, 07 Jul 2011 04:52:34 -0700 (PDT)
Message-ID: <20110707.045234.2227056347170192540.davem@davemloft.net>
References: <20110707.042925.1609726410655229616.davem@davemloft.net>
	<4E15995D.6040405@mev.co.uk>
	<20110707.043625.856190521365086318.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ian.abbott@mev.co.uk, netdev@vger.kernel.org, arnd@arndb.de,
	linux-kernel@vger.kernel.org
To: abbotti@mev.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49900 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755339Ab1GGLwl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2011 07:52:41 -0400
In-Reply-To: <20110707.043625.856190521365086318.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Thu, 07 Jul 2011 04:36:25 -0700 (PDT)

> From: Ian Abbott <abbotti@mev.co.uk>
> Date: Thu, 7 Jul 2011 12:32:45 +0100
> 
>> On 07/07/11 12:29, David Miller wrote:
>>> From: Ian Abbott <abbotti@mev.co.uk>
>>> Date: Thu, 7 Jul 2011 12:18:49 +0100
>>> 
>>>> Reduce the number of variables modified by the loop in do_csum() by 1,
>>>> which seems like a good idea.  On Nios II (a RISC CPU with 3-operand
>>>> instruction set) it reduces the loop from 7 to 6 instructions, including
>>>> the conditional branch.
>>>>
>>>> Signed-off-by: Ian Abbott <abbotti@mev.co.uk>
>>> 
>>> I think you'll overshoot past the end of the buffer when there are
>>> trailing bytes to handle.
>>> 
>>> The whole reason we need the count variable is to handle those
>>> kinds of cases.
>> 
>> I don't think it does.  That's what the & ~3 was for.
> 
> Aha, yes that indeed makes it work.

I've applied this to net-next-2.6, thanks.
