From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: mvneta: mark symbols static where possible
Date: Sun, 18 Sep 2016 15:05:12 +0300
Message-ID: <8cba4a0e-cbf6-ca67-a117-4c558d2c36f1@cogentembedded.com>
References: <1474190445-5887-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        arnd@arndb.de, xie.baoyou@zte.com.cn
To: Baoyou Xie <baoyou.xie@linaro.org>,
        thomas.petazzoni@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f48.google.com ([209.85.215.48]:36755 "EHLO
        mail-lf0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755585AbcIRMFQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 08:05:16 -0400
Received: by mail-lf0-f48.google.com with SMTP id g62so88891557lfe.3
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2016 05:05:15 -0700 (PDT)
In-Reply-To: <1474190445-5887-1-git-send-email-baoyou.xie@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 9/18/2016 12:20 PM, Baoyou Xie wrote:

> We get 2 warnings when building kernel with W=1:
> drivers/net/ethernet/marvell/mvneta.c:639:27: warning: no previous prototype for 'mvneta_get_stats64' [-Wmissing-prototypes]
> drivers/net/ethernet/marvell/mvneta.c:3529:5: warning: no previous prototype for 'mvneta_ethtool_set_link_ksettings' [-Wmissing-prototypes]
>
> In fact, these functions are only used in the file in which they are
> declared and don't need a declaration, but can be made static.
> so this patch marks these functions with 'static'.
>
> Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
> ---
>  drivers/net/ethernet/marvell/mvneta.c | 10 ++++++----
>  1 file changed, 6 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
> index 32f0cc4..03be592 100644
> --- a/drivers/net/ethernet/marvell/mvneta.c
> +++ b/drivers/net/ethernet/marvell/mvneta.c
> @@ -636,8 +636,9 @@ static void mvneta_mib_counters_clear(struct mvneta_port *pp)
>  }
>
>  /* Get System Network Statistics */
> -struct rtnl_link_stats64 *mvneta_get_stats64(struct net_device *dev,
> -					     struct rtnl_link_stats64 *stats)
> +static struct
> +rtnl_link_stats64 *mvneta_get_stats64(struct net_device *dev,

    I'd break the line after * heren not where you did it. This way the 
function type would remain all in one line.

> +				      struct rtnl_link_stats64 *stats)
>  {
>  	struct mvneta_port *pp = netdev_priv(dev);
>  	unsigned int start;
[...]

MBR, Sergei
