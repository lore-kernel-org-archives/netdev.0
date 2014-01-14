From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next V3 0/3] net: Add GRO support for UDP encapsulating
 protocols
Date: Tue, 14 Jan 2014 18:06:55 +0200
Message-ID: <52D5609F.8010301@mellanox.com>
References: <1389715212-14504-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:35704 "EHLO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751413AbaANQKL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 11:10:11 -0500
In-Reply-To: <1389715212-14504-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/01/2014 18:00, Or Gerlitz wrote:
> This series adds GRO handlers for protocols that do UDP encapsulation, with the
> intent of being able to coalesce packets which encapsulate packets belonging to
> the same TCP session.
>
> For GRO purposes, the destination UDP port takes the role of the ether type
> field in the ethernet header or the next protocol in the IP header.
>
> The UDP GRO handler will only attempt to coalesce packets whose destination
> port is registered to have gro handler.
>
> The patches done against net-next ae237b3ede64 "net: 3com: fix
> warning for incorrect type in argument"
>
> Or.
>
>
> v3 --> v4 changes:
>
>    - applied feedback from Tom on some micro-optimizations that save
>      branches and goto directives in the udp gro logic
>
>   - applied feedback from Eric on correct RCU programming for the
>     add/remove flow of the upper protocols udp gro handlers
>
>
> v2 --> v3 changes:
>
>   - moved to use linked list to store the udp gro handlers, this solves the
>     problem of consuming 512KB of memory for the handlers.
>
>   - use a mark on the skb GRO CB data to disallow running the udp gro_receive twice
>     on a packet, this solves the problem of udp encapsulated packets whose inner VM
>     packet is udp and happen to carry a port which has registered offloads - and flush it.
>
>   - invoke the udp offload protocol registration and de-registration from the vxlan driver
>     in a sleepable context
>
> For unclear some reason I got this warning when the vxlan driver deletes the
> udp offload structure
> *** BLURB HERE ***

Sorry for the spam, the above three lines are leftovers from the V3 
cover letter, same for the subject line of this
cover-letter which carries "V3" this *is* V4, will make sure to avoid 
such flushes (....) in the future.

Or.

>
> Or Gerlitz (3):
>    net: Add GRO support for UDP encapsulating protocols
>    net: Export gro_find_by_type helpers
>    net: Add GRO support for vxlan traffic
>
>   drivers/net/vxlan.c       |  117 +++++++++++++++++++++++++++++++--
>   include/linux/netdevice.h |   10 +++-
>   include/net/protocol.h    |    3 +
>   include/net/vxlan.h       |    1 +
>   net/core/dev.c            |    3 +
>   net/ipv4/udp_offload.c    |  157 +++++++++++++++++++++++++++++++++++++++++++++
>   6 files changed, 283 insertions(+), 8 deletions(-)
>
