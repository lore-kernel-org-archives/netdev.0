From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: bridge: accept bridge own MAC address as local
Date: Fri, 12 Aug 2011 09:19:09 -0700
Message-ID: <20110812091909.712fa36e@nehalam.ftrdhcpuser.net>
References: <20110812113024.GA8900@babylon>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Ulrich Weber <ulrich.weber@sophos.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36528 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751959Ab1HLQTF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Aug 2011 12:19:05 -0400
In-Reply-To: <20110812113024.GA8900@babylon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 12 Aug 2011 13:30:24 +0200
Ulrich Weber <ulrich.weber@sophos.com> wrote:

> bridge: accept bridge own MAC address as local
> if MAC address of bridge is manually set (BR_SET_MAC_ADDR). Otherwise
> only MAC addresses of bridge members will work if manually set.
> 
> Signed-off-by: Ulrich Weber <ulrich.weber@sophos.com>
> ---
>  net/bridge/br_input.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
> index f06ee39..3adabe3 100644
> --- a/net/bridge/br_input.c
> +++ b/net/bridge/br_input.c
> @@ -93,7 +93,9 @@ int br_handle_frame_finish(struct sk_buff *skb)
>  			skb2 = skb;
>  
>  		br->dev->stats.multicast++;
> -	} else if ((dst = __br_fdb_get(br, dest)) && dst->is_local) {
> +	} else if ((br->flags & BR_SET_MAC_ADDR &&
> +		    !compare_ether_addr(br->bridge_id.addr, dest)) ||
> +		   ((dst = __br_fdb_get(br, dest)) && dst->is_local)) {
>  		skb2 = skb;
>  		/* Do not forward the packet since it's local. */
>  		skb = NULL;

A cleaner way to do this would be better to put a local entry
in the forwarding database when mac address is manually set.
Then there would not be special case code.
