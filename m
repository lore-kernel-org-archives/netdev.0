From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH] macvlan: Fix checksum errors when ip_summed is CHECKSUM_PARTIAL
Date: Mon, 19 May 2014 17:24:09 -0400
Message-ID: <537A7679.5040102@gmail.com>
References: <1400520254-5142-1-git-send-email-spang@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
To: Michael Spang <spang@chromium.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400520254-5142-1-git-send-email-spang@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/19/2014 01:24 PM, Michael Spang wrote:
> Changing ip_summed from CHECKSUM_PARTIAL to CHECKSUM_UNNECESSARY
> will result in an incorrect checksum if the packet is sent off the box.
> 
> Cc: stable@vger.kernel.org
> Signed-off-by: Michael Spang <spang@chromium.org>
> ---
>  drivers/net/macvlan.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> index 753a8c2..806b56a 100644
> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
> @@ -267,7 +267,9 @@ static int macvlan_queue_xmit(struct sk_buff *skb, struct net_device *dev)
>  
>  	if (vlan->mode == MACVLAN_MODE_BRIDGE) {
>  		const struct ethhdr *eth = (void *)skb->data;
> -		skb->ip_summed = CHECKSUM_UNNECESSARY;
> +
> +		if (skb->ip_summed == CHECKSUM_NONE)
> +			skb->ip_summed = CHECKSUM_UNNECESSARY;
>  
>  		/* send to other bridge ports directly */
>  		if (is_multicast_ether_addr(eth->h_dest)) {
> 

Already done.  See commit f114890cdf84d753f6b41cd0cc44ba51d16313da

-vlad
