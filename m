From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 11/15] nfp: don't use netdev_warn() before netdev
 is registered
Date: Wed, 22 Mar 2017 12:19:31 +0300
Message-ID: <e8320954-1937-0c17-5893-035a4e7c35e4@cogentembedded.com>
References: <20170322005921.10965-1-jakub.kicinski@netronome.com>
 <20170322005921.10965-12-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: oss-drivers@netronome.com, kubakici@wp.pl
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:37769 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758912AbdCVJTf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 05:19:35 -0400
Received: by mail-wm0-f53.google.com with SMTP id n11so31685830wma.0
        for <netdev@vger.kernel.org>; Wed, 22 Mar 2017 02:19:34 -0700 (PDT)
In-Reply-To: <20170322005921.10965-12-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 3/22/2017 3:59 AM, Jakub Kicinski wrote:

> Fix warning which was using netdev_warn() instead of dev_warn()

    I'm seeing nn_warn()...

> to early.

    Too. :-)

> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> ---
>  drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
> index f134f1808b9a..19f9d95faea4 100644
> --- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
> +++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
> @@ -336,9 +336,9 @@ nfp_net_irqs_assign(struct nfp_net *nn, struct msix_entry *irq_entries,
>
>  	if (dp->num_rx_rings > dp->num_r_vecs ||
>  	    dp->num_tx_rings > dp->num_r_vecs)
> -		nn_warn(nn, "More rings (%d,%d) than vectors (%d).\n",
> -			dp->num_rx_rings, dp->num_tx_rings,
> -			dp->num_r_vecs);
> +		dev_warn(nn->dp.dev, "More rings (%d,%d) than vectors (%d).\n",
> +			 dp->num_rx_rings, dp->num_tx_rings,
> +			 dp->num_r_vecs);
>
>  	dp->num_rx_rings = min(dp->num_r_vecs, dp->num_rx_rings);
>  	dp->num_tx_rings = min(dp->num_r_vecs, dp->num_tx_rings);

MBR, Sergei
