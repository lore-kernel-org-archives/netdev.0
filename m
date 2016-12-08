From: Iyappan Subramanian <isubramanian@apm.com>
Subject: Re: [PATCH] drivers: net: xgene: initialize slots
Date: Thu, 8 Dec 2016 10:44:31 -0800
Message-ID: <CAKh23Fk5c48O_ddCZ=OTimdiA1_-F-j5U1H8c+OrcQHnzOsJaQ@mail.gmail.com>
References: <20161208111754.9711-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Keyur Chudgar <kchudgar@apm.com>, netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Colin King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161208111754.9711-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 8, 2016 at 3:17 AM, Colin King <colin.king@canonical.com> wrote:
> From: Colin Ian King <colin.king@canonical.com>
>
> static analysis using cppcheck detected that slots was uninitialized.
> Fix this by initializing it to buf_pool->slots - 1
>
> Found using static analysis with CoverityScan, CID #1387620
>
> Fixes: a9380b0f7be818 ("drivers: net: xgene: Add support for Jumbo frame")
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
> index 6c7eea8..899163c 100644
> --- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
> +++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
> @@ -636,6 +636,7 @@ static void xgene_enet_free_pagepool(struct xgene_enet_desc_ring *buf_pool,
>
>         dev = ndev_to_dev(buf_pool->ndev);
>         head = buf_pool->head;
> +       slots = buf_pool->slots - 1;
>
>         for (i = 0; i < 4; i++) {
>                 frag_size = xgene_enet_get_data_len(le64_to_cpu(desc[i ^ 1]));

Thanks, Colin.

Dan Carpenter <dan.carpenter@oracle.com> posted the fix already and
got accepted.
http://marc.info/?l=linux-netdev&m=148110980224343&w=2

> --
> 2.10.2
>
