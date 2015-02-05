From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net/macb: fix sparse warning
Date: Thu, 05 Feb 2015 08:29:21 -0800
Message-ID: <1423153761.31870.75.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1423150846-7027-1-git-send-email-prabhakar.csengg@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Xander Huff <xander.huff@ni.com>
To: Lad Prabhakar <prabhakar.csengg@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423150846-7027-1-git-send-email-prabhakar.csengg@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-02-05 at 15:40 +0000, Lad Prabhakar wrote:
> From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>
> 
> this patch fixes following sparse warning:
> 
> macb.c:2038:26: warning: symbol 'gem_ethtool_ops' was not declared. Should it be static?
> 
> Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>
> ---
>  Found this issue on linux-next (gcc  version 4.8.2,
>  sparse version  0.4.5-rc1)and applies on top linux-next.
> 
>  drivers/net/ethernet/cadence/macb.h | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
> index 31dc080..e6ad68a 100644
> --- a/drivers/net/ethernet/cadence/macb.h
> +++ b/drivers/net/ethernet/cadence/macb.h
> @@ -821,6 +821,7 @@ struct macb {
>  };
>  
>  extern const struct ethtool_ops macb_ethtool_ops;
> +extern const struct ethtool_ops gem_ethtool_ops;
>  
>  int macb_mii_init(struct macb *bp);
>  int macb_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);

Certainly not.

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 4f7bd13796b87b873a198ffd0760dedbb9077ed4..ad76b8e35a00e188e39d00f4c5f70d97c3df5363 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -2035,7 +2035,7 @@ const struct ethtool_ops macb_ethtool_ops = {
 };
 EXPORT_SYMBOL_GPL(macb_ethtool_ops);
 
-const struct ethtool_ops gem_ethtool_ops = {
+static const struct ethtool_ops gem_ethtool_ops = {
 	.get_settings		= macb_get_settings,
 	.set_settings		= macb_set_settings,
 	.get_regs_len		= macb_get_regs_len,
@@ -2046,7 +2046,6 @@ const struct ethtool_ops gem_ethtool_ops = {
 	.get_strings		= gem_get_ethtool_strings,
 	.get_sset_count		= gem_get_sset_count,
 };
-EXPORT_SYMBOL_GPL(gem_ethtool_ops);
 
 int macb_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
