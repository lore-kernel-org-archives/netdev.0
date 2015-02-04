From: Hartley Sweeten <HartleyS@visionengravers.com>
Subject: RE: [PATCH] net: ep93xx_eth: Delete unnecessary checks before the
 function call "kfree"
Date: Wed, 4 Feb 2015 15:59:32 +0000
Message-ID: <DC148C5AA1CEBA4E87973D432B1C2D88261024FC@P3PWEX4MB008.ex4.secureserver.net>
References: <5307CAA2.8060406@users.sourceforge.net>
 <alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6>
 <530A086E.8010901@users.sourceforge.net>
 <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6>
 <530A72AA.3000601@users.sourceforge.net>
 <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6>
 <530B5FB6.6010207@users.sourceforge.net>
 <alpine.DEB.2.10.1402241710370.2074@hadrien>
 <530C5E18.1020800@users.sourceforge.net>
 <alpine.DEB.2.10.1402251014170.2080@hadrien>
 <530CD2C4.4050903@users.sourceforge.net>
 <alpine.DEB.2.10.1402251840450.7035@hadrien>
 <530CF8FF.8080600@users.sourceforge.net>
 <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6>
 <530DD06F.4090703@users.sourceforge.net>
 <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
 <5317A59D.4@users.sourceforge.net> <54D23415.6070005@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: LKML <linux-kernel@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
	Julia Lawall <julia.lawall@lip6.fr>
To: SF Markus Elfring <elfring@users.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54D23415.6070005@users.sourceforge.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday, February 04, 2015 8:01 AM, Markus Elfring wrote:
> The kfree() function tests whether its argument is NULL and then
> returns immediately. Thus the test around the call is not needed.
>
> This issue was detected by using the Coccinelle software.
>
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
> ---
>  drivers/net/ethernet/cirrus/ep93xx_eth.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/ethernet/cirrus/ep93xx_eth.c b/drivers/net/ethernet/cirrus/ep93xx_eth.c
> index 3a12c09..de9f7c9 100644
> --- a/drivers/net/ethernet/cirrus/ep93xx_eth.c
> +++ b/drivers/net/ethernet/cirrus/ep93xx_eth.c
> @@ -475,8 +475,7 @@ static void ep93xx_free_buffers(struct ep93xx_priv *ep)
>  		if (d)
>  			dma_unmap_single(dev, d, PKT_BUF_SIZE, DMA_FROM_DEVICE);
>  
> -		if (ep->rx_buf[i] != NULL)
> -			kfree(ep->rx_buf[i]);
> +		kfree(ep->rx_buf[i]);
>  	}
>  
>  	for (i = 0; i < TX_QUEUE_ENTRIES; i++) {
> @@ -486,8 +485,7 @@ static void ep93xx_free_buffers(struct ep93xx_priv *ep)
>  		if (d)
>  			dma_unmap_single(dev, d, PKT_BUF_SIZE, DMA_TO_DEVICE);
>  
> -		if (ep->tx_buf[i] != NULL)
> -			kfree(ep->tx_buf[i]);
> +		kfree(ep->tx_buf[i]);
>  	}
>  
>  	dma_free_coherent(dev, sizeof(struct ep93xx_descs), ep->descs,

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>

Thanks
