From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2 7/9] net: mvmdio: Use devm_* API to simplify the code
Date: Tue, 06 May 2014 22:01:10 +0400
Message-ID: <53692366.4000600@cogentembedded.com>
References: <1399396858-14551-1-git-send-email-ezequiel.garcia@free-electrons.com> <1399396858-14551-8-git-send-email-ezequiel.garcia@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Willy Tarreau <w@1wt.eu>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:50406 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751679AbaEFSBA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 14:01:00 -0400
Received: by mail-lb0-f171.google.com with SMTP id 10so2127691lbg.30
        for <netdev@vger.kernel.org>; Tue, 06 May 2014 11:00:59 -0700 (PDT)
In-Reply-To: <1399396858-14551-8-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 05/06/2014 09:20 PM, Ezequiel Garcia wrote:

> This commit makes use of devm_kmalloc() for memory allocation and the
> recently introduced devm_mdiobus_alloc() API to simplify driver's code.
> While here, remove a redundant out of memory error message.

> Acked-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
> Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
> ---
>   drivers/net/ethernet/marvell/mvmdio.c | 18 ++++++------------
>   1 file changed, 6 insertions(+), 12 deletions(-)

> diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
> index b161a52..995e182 100644
> --- a/drivers/net/ethernet/marvell/mvmdio.c
> +++ b/drivers/net/ethernet/marvell/mvmdio.c
[...]
> @@ -208,11 +207,10 @@ static int orion_mdio_probe(struct platform_device *pdev)
>   		 dev_name(&pdev->dev));
>   	bus->parent = &pdev->dev;
>
> -	bus->irq = kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
> -	if (!bus->irq) {
> -		mdiobus_free(bus);
> +	bus->irq = devm_kmalloc(&pdev->dev,
> +				sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);

    I'd rather use devm_kmalloc_array().

WBR, Sergei
