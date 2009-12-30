From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] drivers/atm/lanai.c: use %pM to show MAC address
Date: Wed, 30 Dec 2009 10:59:46 -0800
Message-ID: <1262199586.2545.43.camel@Joe-Laptop.home>
References: <BD79186B4FD85F4B8E60E381CAEE19090200F645@mi8nycmail19.Mi8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: H Hartley Sweeten <hartleys@visionengravers.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753317AbZL3S7t@vger.kernel.org>
In-Reply-To: <BD79186B4FD85F4B8E60E381CAEE19090200F645@mi8nycmail19.Mi8.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2009-12-30 at 13:50 -0500, H Hartley Sweeten wrote:
> Use the %pM kernel extension to display the MAC address.
> diff --git a/drivers/atm/lanai.c b/drivers/atm/lanai.c
> index cf97c34..7fe7c32 100644
> --- a/drivers/atm/lanai.c
> +++ b/drivers/atm/lanai.c
[]
> @@ -2483,14 +2481,8 @@ static int lanai_proc_read(struct atm_dev *atmdev, loff_t *pos, char *page)
>  		return sprintf(page, "revision: board=%d, pci_if=%d\n",
>  		    lanai->board_rev, (int) lanai->pci->revision);
>  	if (left-- == 0)
> -		return sprintf(page, "EEPROM ESI: "
> -		    "%02X:%02X:%02X:%02X:%02X:%02X\n",
> -		    lanai->eeprom[EEPROM_MAC + 0],
> -		    lanai->eeprom[EEPROM_MAC + 1],
> -		    lanai->eeprom[EEPROM_MAC + 2],
> -		    lanai->eeprom[EEPROM_MAC + 3],
> -		    lanai->eeprom[EEPROM_MAC + 4],
> -		    lanai->eeprom[EEPROM_MAC + 5]);
> +		return sprintf(page, "EEPROM ESI: %pM\n",
> +		    &lanai->eeprom[EEPROM_MAC]);

This is a user-visible change from upper case to lower case.
Probably doesn't matter, but maybe...
