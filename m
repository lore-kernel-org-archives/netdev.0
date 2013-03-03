From: Sasha Levin <sasha.levin@oracle.com>
Subject: Re: [PATCH] ircomm: release tty before sleeping potentially indefintely
Date: Sun, 03 Mar 2013 18:17:38 -0500
Message-ID: <5133DA12.8020907@oracle.com>
References: <1362350153-26225-1-git-send-email-sasha.levin@oracle.com> <20130303.174739.1195645942179862011.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, gregkh@linuxfoundation.org, jslaby@suse.cz,
	peter@hurleysoftware.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:46100 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753027Ab3CCXSe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Mar 2013 18:18:34 -0500
In-Reply-To: <20130303.174739.1195645942179862011.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/03/2013 05:47 PM, David Miller wrote:
> From: Sasha Levin <sasha.levin@oracle.com>
> Date: Sun,  3 Mar 2013 17:35:53 -0500
> 
>> ircomm_tty_block_til_ready would hold tty lock while blocking. Since the sleep
>> might take a long time we can prevent other processes from accessing the tty,
>> causing hung tasks and a dead tty.
>>
>> Diagnosed-by: Peter Hurley <peter@hurleysoftware.com>
>> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
> 
> But then you invalidate all of the tty state tests made under
> the lock at the beginning of this function, before enterring
> the loop.  If you drop the lock, those pieces of state could
> change.
> 
> I'm not applying this.

I'm unsure. A similar patch was applied back in 2010 that does the same thing
to a bunch of drivers, including the core tty code (e142a31da "tty: release
BTM while sleeping in block_til_ready").

This IR code looks very much like tty_port_block_til_ready() where it was
okay to do that change, so I should be the same with ircomm_tty_block_til_ready.


Thanks,
Sasha
