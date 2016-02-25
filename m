From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net-next 4/5] net/tun: implement ndo_set_rx_headroom
Date: Thu, 25 Feb 2016 11:49:42 +0100
Message-ID: <1456397382.5100.32.camel@redhat.com>
References: <cover.1456163137.git.pabeni@redhat.com>
	 <38c29993e36ee3446f29a635c2d218e7777f55fe.1456163137.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@kernel.org>,
	Flavio Leitner <fbl@sysclose.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43861 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759460AbcBYKtr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Feb 2016 05:49:47 -0500
In-Reply-To: <38c29993e36ee3446f29a635c2d218e7777f55fe.1456163137.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-02-23 at 13:53 +0100, Paolo Abeni wrote:
> ndo_set_rx_headroom controls the align value used by tun devices to
> allocate skbs on frame reception.
> When the xmit device adds a large encapsulation, this avoids an skb
> head reallocation on forwarding.
> 
> The measured improvement when forwarding towards a vxlan dev with
> frame size below the egress device MTU is around 6% when tunneling over
> ipv6.
> 
> In case of ipv4 tunnels there is no improvement, since the tun
> device default alignment provides enough headroom to avoid the skb
> head reallocation, at least on hosts with 64 bytes cacheline.
> 
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> ---
>  drivers/net/tun.c | 16 +++++++++++++++-
>  1 file changed, 15 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 88bb8cc..5812693 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -187,6 +187,7 @@ struct tun_struct {
>  #define TUN_USER_FEATURES (NETIF_F_HW_CSUM|NETIF_F_TSO_ECN|NETIF_F_TSO| \
>  			  NETIF_F_TSO6|NETIF_F_UFO)
>  
> +	int			align;

This needs to be initialized to NET_SKB_PAD, to preserved the current
behavior.

I'll fix it in v2.

Paolo
