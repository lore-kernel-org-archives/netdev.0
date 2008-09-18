From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] r8169: read MAC address from EEPROM on init
Date: Thu, 18 Sep 2008 22:34:22 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0809182232230.4742@wrl-59.cs.helsinki.fi>
References: <48D25BA2.6070008@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	Edward Hsu <edward_hsu@realtek.com.tw>
To: Ivan Vecera <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:34998 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753963AbYIRTeZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2008 15:34:25 -0400
In-Reply-To: <48D25BA2.6070008@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 18 Sep 2008, Ivan Vecera wrote:

> This fixes the problem when MAC address is set by ifconfig or by
> ip link commands and this address is stored in the device after
> reboot. The power-off is needed to get right MAC address.
> This is problem when Xen daemon is running because it renames the device
> name from ethX to pethX and sets its MAC address to FE:FF:FF:FF:FF:FF.
> After reboot the device is still using FE:FF:FF:FF:FF:FF.
> 
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>
> ---
>  drivers/net/r8169.c |   80 ++++++++++++++++++++++++++++++++++++++++++++++++++-
>  1 files changed, 79 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index befc927..b09a4ec 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -1910,6 +1910,81 @@ static void rtl_disable_msi(struct pci_dev *pdev, struct rtl8169_private *tp)
>  	}
>  }
> 
> +static int rtl_eeprom_read(struct pci_dev *pdev, int cap, int addr, u32 *val)
> +{
> +	int ret, count = 100;
> +	u16 status = 0;
> +	u32 value;

...

> +	*val = cpu_to_le32(value);

Did you check this with sparse?


-- 
 i.
