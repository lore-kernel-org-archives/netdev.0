From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/6] pch_gbe: print invalid MAC address during probe
Date: Mon, 26 May 2014 09:24:28 -0700
Message-ID: <1401121468.519.6.camel@joe-AO725>
References: <1401111639-11507-1-git-send-email-alexander.stein@systec-electronic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Daniel Krueger <daniel.krueger@systec-electronic.com>,
	netdev@vger.kernel.org
To: Alexander Stein <alexander.stein@systec-electronic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0021.hostedemail.com ([216.40.44.21]:47210 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750855AbaEZQYb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2014 12:24:31 -0400
In-Reply-To: <1401111639-11507-1-git-send-email-alexander.stein@systec-electronic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-05-26 at 15:40 +0200, Alexander Stein wrote:
> show the actual offending MAC address instead of just
> rejecting it
[]
> diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
[]
> @@ -2674,6 +2674,7 @@ static int pch_gbe_probe(struct pci_dev *pdev,
>  		 */
>  		dev_err(&pdev->dev, "Invalid MAC address, "
>  		                    "interface disabled.\n");
> +		dev_err(&pdev->dev, "%pM\n", adapter->hw.mac.addr);

Nicer I think on a single line
using just one dev_err

		dev_err(&pdev->dev, "Invalid MAC %pM - interface disabled\n",
			adapter->hw.mac.addr);
