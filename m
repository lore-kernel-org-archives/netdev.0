From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 4/10] drivers/net/can/flexcan.c: add missing clk_put
Date: Wed, 01 Jun 2011 10:26:15 -0700
Message-ID: <1306949175.32125.20.camel@Joe-Laptop>
References: <1306948213-20767-4-git-send-email-julia@diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	kernel-janitors@vger.kernel.org, socketcan-core@lists.berlios.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Julia Lawall <julia@diku.dk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1306948213-20767-4-git-send-email-julia@diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-06-01 at 19:10 +0200, Julia Lawall wrote:
> The failed_get label is used after the call to clk_get has succeeded, so it
> should be moved up above the call to clk_put.
[]
> diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
[]
> @@ -978,8 +978,8 @@ static int __devinit flexcan_probe(struct platform_device *pdev)
>   failed_map:
>  	release_mem_region(mem->start, mem_size);
>   failed_req:
> -	clk_put(clk);
>   failed_get:
> +	clk_put(clk);
>   failed_clock:
>  	return err;

If this is correct, it might be better to rename all the
uses of failed_req to failed_get and delete label failed_req.
