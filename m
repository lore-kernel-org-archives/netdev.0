From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] SCTP: Fix chunk parameter processing bug
Date: Wed, 05 Mar 2008 08:53:45 -0500
Message-ID: <47CEA5E9.80202@hp.com>
References: <47CE474B.3040709@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:29516 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752279AbYCENxs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 08:53:48 -0500
In-Reply-To: <47CE474B.3040709@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gui Jianfeng wrote:
> If an address family is not listed in "Supported Address Types" parameter(INIT Chunk), 
> but the packet is sent by that family, this address family should be considered as supported by peer.
> Otherwise, an error condition will occur. For instance, if kernel receives an IPV6 SCTP INIT chunk with
> "Support Address Types" parameter which indicates just supporting IPV4 Address family. Kernel will reply
> an IPV6 SCTP INIT ACK packet, but the source ipv6 address in ipv6 header will be vacant. This is not correct.
> 
> refer to RFC4460 as following:
>       IMPLEMENTATION NOTE: If an SCTP endpoint lists in the 'Supported
>       Address Types' parameter either IPv4 or IPv6, but uses the other
>       family for sending the packet containing the INIT chunk, or if it
>       also lists addresses of the other family in the INIT chunk, then
>       the address family that is not listed in the 'Supported Address
>       Types' parameter SHOULD also be considered as supported by the
>       receiver of the INIT chunk.  The receiver of the INIT chunk SHOULD
>       NOT respond with any kind of error indication.
> 
> Here is a fix to comply to RFC.
> 
> Signed-off-by: Gui Jianfeng <guijianfeng@cn.fujitsu.com>

Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Thanks for catching this.
-vlad

