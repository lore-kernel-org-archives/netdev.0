From: Iyappan Subramanian <isubramanian@apm.com>
Subject: Re: [patch -next] net: eth: xgene: devm_ioremap() returns NULL on error
Date: Fri, 9 Jan 2015 14:56:53 -0800
Message-ID: <CAKh23FkWyiXG38RtbWK3nkX9jC0YkDqfvFnGLtSp0f+8N=KhPw@mail.gmail.com>
References: <20150108105211.GB10597@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Feng Kan <fkan@apm.com>, Keyur Chudgar <kchudgar@apm.com>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>,
	netdev <netdev@vger.kernel.org>, kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20150108105211.GB10597@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 8, 2015 at 2:52 AM, Dan Carpenter <dan.carpenter@oracle.com> wrote:
> devm_ioremap() returns NULL on failure, it doesn't return an ERR_PTR.
>
> Fixes: de7b5b3d790a ('net: eth: xgene: change APM X-Gene SoC platform ethernet to support ACPI')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>
> diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
> index 1e56bf3..02add38 100644
> --- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
> +++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
> @@ -804,9 +804,9 @@ static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
>                 return -ENODEV;
>         }
>         pdata->base_addr = devm_ioremap(dev, res->start, resource_size(res));
> -       if (IS_ERR(pdata->base_addr)) {
> +       if (!pdata->base_addr) {
>                 dev_err(dev, "Unable to retrieve ENET Port CSR region\n");
> -               return PTR_ERR(pdata->base_addr);
> +               return -ENOMEM;
>         }
>
>         res = platform_get_resource(pdev, IORESOURCE_MEM, RES_RING_CSR);
> @@ -816,9 +816,9 @@ static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
>         }
>         pdata->ring_csr_addr = devm_ioremap(dev, res->start,
>                                                         resource_size(res));
> -       if (IS_ERR(pdata->ring_csr_addr)) {
> +       if (!pdata->ring_csr_addr) {
>                 dev_err(dev, "Unable to retrieve ENET Ring CSR region\n");
> -               return PTR_ERR(pdata->ring_csr_addr);
> +               return -ENOMEM;
>         }
>
>         res = platform_get_resource(pdev, IORESOURCE_MEM, RES_RING_CMD);
> @@ -828,9 +828,9 @@ static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
>         }
>         pdata->ring_cmd_addr = devm_ioremap(dev, res->start,
>                                                         resource_size(res));
> -       if (IS_ERR(pdata->ring_cmd_addr)) {
> +       if (!pdata->ring_cmd_addr) {
>                 dev_err(dev, "Unable to retrieve ENET Ring command region\n");
> -               return PTR_ERR(pdata->ring_cmd_addr);
> +               return -ENOMEM;
>         }
>
>         ret = platform_get_irq(pdev, 0);

Acked-by: Iyappan Subramanian <isubramanian@apm.com>
