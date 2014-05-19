From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] macvlan: Fix checksum errors when ip_summed is
 CHECKSUM_PARTIAL
Date: Mon, 19 May 2014 10:44:53 -0700
Message-ID: <1400521493.5367.61.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1400520254-5142-1-git-send-email-spang@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Daniel Lezcano <daniel.lezcano@free.fr>
To: Michael Spang <spang@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400520254-5142-1-git-send-email-spang@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-05-19 at 13:24 -0400, Michael Spang wrote:
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

Hi Michael

Any idea why commit 12a2856b604476c27d85a5f9a57ae1661fc46019
added this stuff then ?

You should give more infos of your use case.

CC Daniel Lezcano <daniel.lezcano@free.fr>

I removed stable@ , as stable submissions are not done like that.
