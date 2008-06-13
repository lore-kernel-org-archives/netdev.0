From: "Bryan Wu" <cooloney@kernel.org>
Subject: Re: dm9000: Remove the 2 resources probe scheme.
Date: Fri, 13 Jun 2008 22:29:45 +0800
Message-ID: <386072610806130729k77d1801lb615ffafb3d0117f@mail.gmail.com>
References: <200806131458.58410.laurentp@cse-semaphore.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Ben Dooks" <ben-linux@fluff.org>
To: "Laurent Pinchart" <laurentp@cse-semaphore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:38075 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755560AbYFMO35 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jun 2008 10:29:57 -0400
Received: by yw-out-2324.google.com with SMTP id 9so2500811ywe.1
        for <netdev@vger.kernel.org>; Fri, 13 Jun 2008 07:29:45 -0700 (PDT)
In-Reply-To: <200806131458.58410.laurentp@cse-semaphore.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 13, 2008 at 8:58 PM, Laurent Pinchart
<laurentp@cse-semaphore.com> wrote:
> The dm9000 driver accepts either 2 or 3 resources to describe the platform
> devices. The 2 resources case abuses the ioresource mechanism by passing
> ioremap()ed memory through the platform device resources. This patch removes
> that case and converts boards that were using it to the 3 resources scheme.
>
> Signed-off-by: Laurent Pinchart <laurentp@cse-semaphore.com>
> ---
>  arch/blackfin/mach-bf527/boards/ezkit.c         |    7 ++-
>  arch/blackfin/mach-bf533/boards/H8606.c         |    7 ++-
>  arch/blackfin/mach-bf537/boards/generic_board.c |    7 ++-
>  arch/blackfin/mach-bf537/boards/stamp.c         |    7 ++-

IMO, this patch can be split into two parts, one for Blackfin and the
other for dm9000 driver.

-Bryan

>  drivers/net/dm9000.c                            |  104 +++++++++-------------
>  5 files changed, 67 insertions(+), 65 deletions(-)
>
> diff --git a/arch/blackfin/mach-bf527/boards/ezkit.c b/arch/blackfin/mach-bf527/boards/ezkit.c
> index 5958eec..689b69c 100644
> --- a/arch/blackfin/mach-bf527/boards/ezkit.c
> +++ b/arch/blackfin/mach-bf527/boards/ezkit.c
> @@ -323,10 +323,15 @@ static struct platform_device smc91x_device = {
>  static struct resource dm9000_resources[] = {
>        [0] = {
>                .start  = 0x203FB800,
> -               .end    = 0x203FB800 + 8,
> +               .end    = 0x203FB800 + 1,
>                .flags  = IORESOURCE_MEM,
>        },
>        [1] = {
> +               .start  = 0x203FB800 + 4,
> +               .end    = 0x203FB800 + 5,
> +               .flags  = IORESOURCE_MEM,
> +       },
> +       [2] = {
>                .start  = IRQ_PF9,
>                .end    = IRQ_PF9,
>                .flags  = (IORESOURCE_IRQ | IORESOURCE_IRQ_HIGHEDGE),
> diff --git a/arch/blackfin/mach-bf533/boards/H8606.c b/arch/blackfin/mach-bf533/boards/H8606.c
> index 7cc4864..4103a97 100644
> --- a/arch/blackfin/mach-bf533/boards/H8606.c
> +++ b/arch/blackfin/mach-bf533/boards/H8606.c
> @@ -65,10 +65,15 @@ static struct platform_device rtc_device = {
>  static struct resource dm9000_resources[] = {
>        [0] = {
>                .start  = 0x20300000,
> -               .end    = 0x20300000 + 8,
> +               .end    = 0x20300000 + 1,
>                .flags  = IORESOURCE_MEM,
>        },
>        [1] = {
> +               .start  = 0x20300000 + 4,
> +               .end    = 0x20300000 + 5,
> +               .flags  = IORESOURCE_MEM,
> +       },
> +       [2] = {
>                .start  = IRQ_PF10,
>                .end    = IRQ_PF10,
>                .flags  = (IORESOURCE_IRQ | IORESOURCE_IRQ_HIGHEDGE),
> diff --git a/arch/blackfin/mach-bf537/boards/generic_board.c b/arch/blackfin/mach-bf537/boards/generic_board.c
> index 7d25082..01b63e2 100644
> --- a/arch/blackfin/mach-bf537/boards/generic_board.c
> +++ b/arch/blackfin/mach-bf537/boards/generic_board.c
> @@ -166,10 +166,15 @@ static struct platform_device smc91x_device = {
>  static struct resource dm9000_resources[] = {
>        [0] = {
>                .start  = 0x203FB800,
> -               .end    = 0x203FB800 + 8,
> +               .end    = 0x203FB800 + 1,
>                .flags  = IORESOURCE_MEM,
>        },
>        [1] = {
> +               .start  = 0x203FB800 + 4,
> +               .end    = 0x203FB800 + 5,
> +               .flags  = IORESOURCE_MEM,
> +       },
> +       [2] = {
>                .start  = IRQ_PF9,
>                .end    = IRQ_PF9,
>                .flags  = (IORESOURCE_IRQ | IORESOURCE_IRQ_HIGHEDGE),
> diff --git a/arch/blackfin/mach-bf537/boards/stamp.c b/arch/blackfin/mach-bf537/boards/stamp.c
> index 671f9d6..16dfeaf 100644
> --- a/arch/blackfin/mach-bf537/boards/stamp.c
> +++ b/arch/blackfin/mach-bf537/boards/stamp.c
> @@ -205,10 +205,15 @@ static struct platform_device smc91x_device = {
>  static struct resource dm9000_resources[] = {
>        [0] = {
>                .start  = 0x203FB800,
> -               .end    = 0x203FB800 + 8,
> +               .end    = 0x203FB800 + 1,
>                .flags  = IORESOURCE_MEM,
>        },
>        [1] = {
> +               .start  = 0x203FB800 + 4,
> +               .end    = 0x203FB800 + 5,
> +               .flags  = IORESOURCE_MEM,
> +       },
> +       [2] = {
>                .start  = IRQ_PF9,
>                .end    = IRQ_PF9,
>                .flags  = (IORESOURCE_IRQ | IORESOURCE_IRQ_HIGHEDGE),
> diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
> index 6bc8924..fca7831 100644
> --- a/drivers/net/dm9000.c
> +++ b/drivers/net/dm9000.c
> @@ -528,7 +528,6 @@ dm9000_probe(struct platform_device *pdev)
>        struct board_info *db;  /* Point a board information structure */
>        struct net_device *ndev;
>        const unsigned char *mac_src;
> -       unsigned long base;
>        int ret = 0;
>        int iosize;
>        int i;
> @@ -561,78 +560,61 @@ dm9000_probe(struct platform_device *pdev)
>        if (pdev->num_resources < 2) {
>                ret = -ENODEV;
>                goto out;
> -       } else if (pdev->num_resources == 2) {
> -               base = pdev->resource[0].start;
> -
> -               if (!request_mem_region(base, 4, ndev->name)) {
> -                       ret = -EBUSY;
> -                       goto out;
> -               }
> -
> -               ndev->base_addr = base;
> -               ndev->irq = pdev->resource[1].start;
> -               db->io_addr = (void __iomem *)base;
> -               db->io_data = (void __iomem *)(base + 4);
> +       }
>
> -               /* ensure at least we have a default set of IO routines */
> -               dm9000_set_io(db, 2);
> +       db->addr_res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +       db->data_res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
> +       db->irq_res  = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
>
> -       } else {
> -               db->addr_res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> -               db->data_res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
> -               db->irq_res  = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
> -
> -               if (db->addr_res == NULL || db->data_res == NULL ||
> -                   db->irq_res == NULL) {
> -                       dev_err(db->dev, "insufficient resources\n");
> -                       ret = -ENOENT;
> -                       goto out;
> -               }
> +       if (db->addr_res == NULL || db->data_res == NULL ||
> +           db->irq_res == NULL) {
> +               dev_err(db->dev, "insufficient resources\n");
> +               ret = -ENOENT;
> +               goto out;
> +       }
>
> -               i = res_size(db->addr_res);
> -               db->addr_req = request_mem_region(db->addr_res->start, i,
> -                                                 pdev->name);
> +       iosize = res_size(db->addr_res);
> +       db->addr_req = request_mem_region(db->addr_res->start, iosize,
> +                                         pdev->name);
>
> -               if (db->addr_req == NULL) {
> -                       dev_err(db->dev, "cannot claim address reg area\n");
> -                       ret = -EIO;
> -                       goto out;
> -               }
> -
> -               db->io_addr = ioremap(db->addr_res->start, i);
> +       if (db->addr_req == NULL) {
> +               dev_err(db->dev, "cannot claim address reg area\n");
> +               ret = -EIO;
> +               goto out;
> +       }
>
> -               if (db->io_addr == NULL) {
> -                       dev_err(db->dev, "failed to ioremap address reg\n");
> -                       ret = -EINVAL;
> -                       goto out;
> -               }
> +       db->io_addr = ioremap(db->addr_res->start, iosize);
>
> -               iosize = res_size(db->data_res);
> -               db->data_req = request_mem_region(db->data_res->start, iosize,
> -                                                 pdev->name);
> +       if (db->io_addr == NULL) {
> +               dev_err(db->dev, "failed to ioremap address reg\n");
> +               ret = -EINVAL;
> +               goto out;
> +       }
>
> -               if (db->data_req == NULL) {
> -                       dev_err(db->dev, "cannot claim data reg area\n");
> -                       ret = -EIO;
> -                       goto out;
> -               }
> +       iosize = res_size(db->data_res);
> +       db->data_req = request_mem_region(db->data_res->start, iosize,
> +                                         pdev->name);
>
> -               db->io_data = ioremap(db->data_res->start, iosize);
> +       if (db->data_req == NULL) {
> +               dev_err(db->dev, "cannot claim data reg area\n");
> +               ret = -EIO;
> +               goto out;
> +       }
>
> -               if (db->io_data == NULL) {
> -                       dev_err(db->dev,"failed to ioremap data reg\n");
> -                       ret = -EINVAL;
> -                       goto out;
> -               }
> +       db->io_data = ioremap(db->data_res->start, iosize);
>
> -               /* fill in parameters for net-dev structure */
> +       if (db->io_data == NULL) {
> +               dev_err(db->dev,"failed to ioremap data reg\n");
> +               ret = -EINVAL;
> +               goto out;
> +       }
>
> -               ndev->base_addr = (unsigned long)db->io_addr;
> -               ndev->irq       = db->irq_res->start;
> +       /* fill in parameters for net-dev structure */
> +       ndev->base_addr = (unsigned long)db->io_addr;
> +       ndev->irq       = db->irq_res->start;
>
> -               /* ensure at least we have a default set of IO routines */
> -               dm9000_set_io(db, iosize);
> -       }
> +       /* ensure at least we have a default set of IO routines */
> +       dm9000_set_io(db, iosize);
>
>        /* check to see if anything is being over-ridden */
>        if (pdata != NULL) {
> --
> 1.5.0
>
>
> --
> Laurent Pinchart
> CSE Semaphore Belgium
>
> Chaussee de Bruxelles, 732A
> B-1410 Waterloo
> Belgium
>
> T +32 (2) 387 42 59
> F +32 (2) 387 42 75
>
