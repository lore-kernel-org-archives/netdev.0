From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] alx: Reset phy speed after resume
Date: Thu, 14 Nov 2013 17:19:35 +0100
Message-ID: <1384445975.13941.38.camel@jlt4.sipsolutions.net>
References: <1384445773.29057.5.camel@localhost.tld>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jcliburn@gmail.com, chris.snook@gmail.com, davem@davemloft.net,
	wangyijing@huawei.com, maarten.lankhorst@canonical.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: hahnjo <linux@hahnjo.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:49322 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754589Ab3KNQTo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 11:19:44 -0500
In-Reply-To: <1384445773.29057.5.camel@localhost.tld>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-14 at 17:16 +0100, hahnjo wrote:
> From 27744b24f9291782c1342dbd6cac511e68da907c Mon Sep 17 00:00:00 2001
> From: hahnjo <hahnjo@hahnjo.de>

You probably want that to be your full name for the commit log?

> Date: Tue, 12 Nov 2013 18:19:24 +0100
> Subject: [PATCH] alx: Reset phy speed after resume
> 
> This fixes bug 62491 (https://bugzilla.kernel.org/show_bug.cgi?id=62491).
> After resuming some users got the following error flooding the kernel log:
> alx 0000:02:00.0: invalid PHY speed/duplex: 0xffff

Acked-by: Johannes Berg <johannes@sipsolutions.net>

> Signed-off-by: Jonas Hahnfeld <linux@hahnjo.de>
> ---
>  drivers/net/ethernet/atheros/alx/main.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet/atheros/alx/main.c
> index fc95b23..6305a5d 100644
> --- a/drivers/net/ethernet/atheros/alx/main.c
> +++ b/drivers/net/ethernet/atheros/alx/main.c
> @@ -1389,6 +1389,9 @@ static int alx_resume(struct device *dev)
>  {
>  	struct pci_dev *pdev = to_pci_dev(dev);
>  	struct alx_priv *alx = pci_get_drvdata(pdev);
> +	struct alx_hw *hw = &alx->hw;
> +
> +	alx_reset_phy(hw);
>  
>  	if (!netif_running(alx->dev))
>  		return 0;
