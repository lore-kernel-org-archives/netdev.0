From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [git pull] firewire net: resource management improvements
Date: Fri, 22 Mar 2013 12:34:23 +0900
Message-ID: <1363923263.16608.14.camel@cirrhata>
References: <5139419A.2040309@linux-ipv6.org>
	 <20130313151919.68068bae@stein>
	 <20130313.102448.1103259275832948992.davem@davemloft.net>
	 <20130313163742.73a3a842@stein>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: Stefan Richter <stefanr@s5r6.in-berlin.de>,
	linux1394-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:45820 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752706Ab3CVDbN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 23:31:13 -0400
In-Reply-To: <20130313163742.73a3a842@stein>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

would you consider pulling this one to net-next, please?
I can prepare rebased tree, if you want.

Thanks.

--yoshfuji

Stefan Richter wrote:
> David,
> 
> please pull from the tag "firewire-net-resource-mgt" at
> 
>     git://git.kernel.org/pub/scm/linux/kernel/git/ieee1394/linux1394.git firewire-net-resource-mgt
> 
> to receive the following firewire-net driver changes:
>   - fix memory leak and kmap leak at shutdown
>   - release IR DMA context already at ifdown rather than shutdown
>     (many controllers have got only 4 of them, so let's not hold it
>     longer than strictly necessary)
>   - misc startup/shutdown changes which prepare for later addition
>     of IPv6-over-1394 support
> 
> YOSHIFUJI Hideaki (11):
>       firewire net: No need to reset dev->local_fifo after failure of fw_core_add_address_handler().
>       firewire net: Introduce fwnet_fifo_{start, stop}() helpers.
>       firewire net: Setup broadcast and local fifo independently.
>       firewire net: Check dev->broadcast_state inside fwnet_broadcast_start().
>       firewire net: Fix memory leakage in fwnet_remove().
>       firewire net: Clear dev->broadcast_rcv_context and dev->broadcast_state after destruction of context.
>       firewire net: Omit checking dev->broadcast_rcv_context in fwnet_broadcast_start().
>       firewire net: Fix leakage of kmap for broadcast receive buffer.
>       firewire net: Allocate dev->broadcast_rcv_buffer_ptrs early.
>       firewire net: Introduce fwnet_broadcast_stop() to destroy broadcast resources.
>       firewire net: Release broadcast/fifo resources on ifdown.
> 
>  drivers/firewire/net.c | 177 +++++++++++++++++++--------------
>  1 file changed, 105 insertions(+), 72 deletions(-)
> 
> Thanks,
