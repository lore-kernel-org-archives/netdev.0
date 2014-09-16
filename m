From: David L Stevens <david.stevens@oracle.com>
Subject: Re: [PATCHv4 net-next 2/3] sunvnet: allow admin to set sunvnet MTU
Date: Tue, 16 Sep 2014 14:51:37 -0400
Message-ID: <541886B9.3010206@oracle.com>
References: <541785D8.5030101@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:50638 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755282AbaIPSvo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 14:51:44 -0400
In-Reply-To: <541785D8.5030101@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 09/15/2014 08:35 PM, David L Stevens wrote:

>   */
>  #define VNET_TX_TIMEOUT			(5 * HZ)
>  
> -#define VNET_MAXPACKET			1518ULL /* ETH_FRAMELEN + VLAN_HDR */
> +#define VNET_MAXPACKET			65553ULL /* 64K-1  +ETH HDR +VLAN HDR*/
>  #define VNET_TX_RING_SIZE		512
>  #define VNET_TX_WAKEUP_THRESH(dr)	((dr)->pending / 4)

While looking at adding TSO support, I've turned up a bug with this.

The transmit buffer mapping should be using a cookie per-page and this increases
the page count (without page alignment) from 2 with a 1500-byte MTU to 10 with a 64K MTU
+ framing and allowing from unaligned buffers.

I think it worked during my testing because the pages were contiguous, but the tx buffer
allocation code is assuming 2 pages (and 2 cookies) max.

So, it's incorrect. I'll fix and repost; please don't apply these yet.

							+-DLS
