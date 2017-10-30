From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH] net: ethernet: slicoss: remove redundant initialization
 of idx
Date: Mon, 30 Oct 2017 11:04:49 -0700
Message-ID: <20171030110449.3aea9670@cakuba.netronome.com>
References: <20171029133809.6831-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Lino Sanfilippo <LinoSanfilippo@gmx.de>, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171029133809.6831-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 29 Oct 2017 13:38:09 +0000, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> Variable idx is being initialized and later on over-written by
> a new value in a do-loop without the initial value ever being
> read. Hence the initializion is redundant and can be removed.
> Cleans up clang warning:
> 
> drivers/net/ethernet/alacritech/slicoss.c:358:15: warning: Value
> stored to 'idx' during its initialization is never read
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  drivers/net/ethernet/alacritech/slicoss.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/alacritech/slicoss.c b/drivers/net/ethernet/alacritech/slicoss.c
> index 15a8096c60df..ac8004186fa8 100644
> --- a/drivers/net/ethernet/alacritech/slicoss.c
> +++ b/drivers/net/ethernet/alacritech/slicoss.c
> @@ -355,7 +355,7 @@ static void slic_xmit_complete(struct slic_device *sdev)
>  {
>  	struct slic_tx_queue *txq = &sdev->txq;
>  	struct net_device *dev = sdev->netdev;
> -	unsigned int idx = txq->done_idx;
> +	unsigned int idx;
>  	struct slic_tx_buffer *buff;
>  	unsigned int frames = 0;
>  	unsigned int bytes = 0;

You should probably reorder the variables now so they stay longest to
shortest.
