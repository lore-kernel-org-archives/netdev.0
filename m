From: David Dillow <dave@thedillows.org>
Subject: Re: [PATCH] drivers: net: ethernet: 3com: fix return value
Date: Fri, 23 Dec 2016 17:05:54 -0800
Message-ID: <1482541554.16278.2.camel@dillow-glaptop.roam.corp.google.com>
References: <1482534015-7828-1-git-send-email-thomas.preisner+linux@fau.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-kernel@i4.cs.fau.de, milan.stephan+linux@fau.de
To: Thomas Preisner <thomas.preisner+linux@fau.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1482534015-7828-1-git-send-email-thomas.preisner+linux@fau.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2016-12-24 at 00:00 +0100, Thomas Preisner wrote:
> diff --git a/drivers/net/ethernet/3com/typhoon.c b/drivers/net/ethernet/3com/typhoon.c
> index a0cacbe..9a3ab58 100644
> --- a/drivers/net/ethernet/3com/typhoon.c
> +++ b/drivers/net/ethernet/3com/typhoon.c
> @@ -2404,6 +2404,7 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>  
>  	if(!is_valid_ether_addr(dev->dev_addr)) {
>  		err_msg = "Could not obtain valid ethernet address, aborting";
> +		err = -EIO;
>  		goto error_out_reset;

The change above is fine, but the other two should use the return value
from the failing function call.


> @@ -2413,6 +2414,7 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>  	INIT_COMMAND_WITH_RESPONSE(&xp_cmd, TYPHOON_CMD_READ_VERSIONS);
>  	if(typhoon_issue_command(tp, 1, &xp_cmd, 3, xp_resp) < 0) {
>  		err_msg = "Could not get Sleep Image version";
> +		err = -EIO;
>  		goto error_out_reset;
>  	}
>  
> @@ -2455,6 +2457,7 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>  
>  	if(register_netdev(dev) < 0) {
>  		err_msg = "unable to register netdev";
> +		err = -EIO;
>  		goto error_out_reset;
>  	}
>  
