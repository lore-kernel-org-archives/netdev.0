From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] rtnetlink: fix frame size warning in rtnl_fill_ifinfo
Date: Mon, 16 Nov 2015 23:18:49 +0100
Message-ID: <1447712329.2095039.441554865.621B2AF9@webmail.messagingengine.com>
References: <1447671903-17975-1-git-send-email-hannes@stressinduktion.org>
 <20151116.153837.635003227845494331.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:40833 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751526AbbKPWSu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 17:18:50 -0500
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id E35052062A
	for <netdev@vger.kernel.org>; Mon, 16 Nov 2015 17:18:49 -0500 (EST)
In-Reply-To: <20151116.153837.635003227845494331.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, Nov 16, 2015, at 21:38, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Mon, 16 Nov 2015 12:05:03 +0100
> 
> > By declaring the huge stack allocations as static. We can do so
> > because we hold rtnl.
> 
> Look across the tree, this is an idiom copied all over the place.
> If putting a rtnl_link_stats64 object on the stack is truly a
> problem, we have a lot of spots to fix.
> 
> I do not think, therefore, that this solution is tenable, we
> need something that handles all cases properly.

I just wanted to shut up the gcc warning which is added if a function
uses more than 2048 bytes of stack space. We normally don't have the
problem and could also divide the function into two, but I don't see a
general solution to the problem. Mostly they need to be custom tailored
to the specific usage.

I can have a look if we can use kmalloc based storage for the stats, but
this also means that we add another NULL pointer check and error
handling for those cases. Let me have a look!

Bye,
Hannes
