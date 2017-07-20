From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH 1/2] net: mvneta: remove bogus use of
Date: Thu, 20 Jul 2017 17:06:21 +0200
Message-ID: <8760en5es2.fsf@free-electrons.com>
References: <20170720142711.12847-1-robh@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        Frank Rowand <frowand.list@gmail.com>,
        Marcin Wojtas <mw@semihalf.com>
To: Rob Herring <robh@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:45192 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935186AbdGTPGd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2017 11:06:33 -0400
In-Reply-To: <20170720142711.12847-1-robh@kernel.org> (Rob Herring's message
        of "Thu, 20 Jul 2017 09:27:10 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Rob,
 
 On jeu., juil. 20 2017, Rob Herring <robh@kernel.org> wrote:

(Adding Marcin in CC who wrote this part of code)

> Nothing sets ever sets data, so it is always NULL. Remove it as this is
> the only user of data ptr in the whole kernel, and it is going to be
> removed from struct device_node.

Actually the use of device_node.data ptr is not bogus and it is set in
mvneta_bm_probe:
http://elixir.free-electrons.com/linux/latest/source/drivers/net/ethernet/marvell/mvneta_bm.c#L433

Your patch will break the BM support on this driver. So if you need to
remove this data ptr, then you have to offer an alternative for it.

Thanks,

Gregory

>
> Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> Signed-off-by: Rob Herring <robh@kernel.org>
> ---
> Probably there's a better fix here to actually enable the h/w buffer 
> manager.
>
> I intend to take this thru the DT tree as patch 2 is dependent on this.
>
> Rob
>
>  drivers/net/ethernet/marvell/mvneta.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
> index 0aab74c2a209..5624f4b49f9d 100644
> --- a/drivers/net/ethernet/marvell/mvneta.c
> +++ b/drivers/net/ethernet/marvell/mvneta.c
> @@ -4296,8 +4296,8 @@ static int mvneta_probe(struct platform_device *pdev)
>  
>  	/* Obtain access to BM resources if enabled and already initialized */
>  	bm_node = of_parse_phandle(dn, "buffer-manager", 0);
> -	if (bm_node && bm_node->data) {
> -		pp->bm_priv = bm_node->data;
> +	if (bm_node) {
> +		pp->bm_priv = NULL;
>  		err = mvneta_bm_port_init(pdev, pp);
>  		if (err < 0) {
>  			dev_info(&pdev->dev, "use SW buffer management\n");
> -- 
> 2.11.0
>

-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
