From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH] vxlan: Update tx_errors statistics if vxlan_build_skb
 return err.
Date: Sun, 4 Sep 2016 16:12:33 +0200
Message-ID: <20160904161233.063d0009@griffin>
References: <1472986371-75583-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472986371-75583-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun,  4 Sep 2016 18:52:51 +0800, Haishuang Yan wrote:
> If vxlan_build_skb return err < 0, tx_errors should be also increased.
> 
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
> ---
>  drivers/net/vxlan.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index f605a36..2c72dcd 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -2103,6 +2103,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
>  				      vni, md, flags, udp_sum);
>  		if (err < 0) {
>  			dst_release(ndst);
> +			dev->stats.tx_errors++;
>  			return;
>  		}
>  		udp_tunnel6_xmit_skb(ndst, sk, skb, dev,

Acked-by: Jiri Benc <jbenc@redhat.com>

The error path in vxlan_xmit_one deserves complete rework, though.

 Jiri
