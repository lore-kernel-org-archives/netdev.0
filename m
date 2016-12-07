From: Iyappan Subramanian <isubramanian@apm.com>
Subject: Re: [patch] drivers: net: xgene: uninitialized variable in xgene_enet_free_pagepool()
Date: Wed, 7 Dec 2016 12:46:51 -0800
Message-ID: <CAKh23F=PWFz9v8XgEXyjSZpUjUxn=W3UUMBokqiL-74eZTeuow@mail.gmail.com>
References: <20161207111424.GA5507@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Keyur Chudgar <kchudgar@apm.com>, netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161207111424.GA5507@elgon.mountain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 7, 2016 at 3:14 AM, Dan Carpenter <dan.carpenter@oracle.com> wrote:
> We never set "slots" in this function.
>
> Fixes: a9380b0f7be8 ("drivers: net: xgene: Add support for Jumbo frame")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
> I copied how slots gets set in xgene_enet_rx_frame().  Static analysis.
> Not tested.
>
> diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
> index 6c7eea8b36af..884a334e82d0 100644
> --- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
> +++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
> @@ -635,6 +635,7 @@ static void xgene_enet_free_pagepool(struct xgene_enet_desc_ring *buf_pool,
>                 return;
>
>         dev = ndev_to_dev(buf_pool->ndev);
> +       slots = buf_pool->slots - 1;
>         head = buf_pool->head;
>
>         for (i = 0; i < 4; i++) {

Thanks.

Acked-by: Iyappan Subramanian <isubramanian@apm.com>
