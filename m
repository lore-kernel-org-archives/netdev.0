From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] r8169: read MAC address from EEPROM on init
Date: Sun, 21 Sep 2008 01:04:54 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0809210100020.16838@wrl-59.cs.helsinki.fi>
References: <48D25BA2.6070008@redhat.com> <Pine.LNX.4.64.0809182235550.4742@wrl-59.cs.helsinki.fi>
 <48D3A381.1080500@redhat.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-1975253372-1221948084=:16838"
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Netdev <netdev@vger.kernel.org>,
	Edward Hsu <edward_hsu@realtek.com.tw>
To: Ivan Vecera <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:38233 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753952AbYITWE4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 18:04:56 -0400
In-Reply-To: <48D3A381.1080500@redhat.com>
Content-ID: <Pine.LNX.4.64.0809210101280.16838@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1975253372-1221948084=:16838
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0809210101281.16838@wrl-59.cs.helsinki.fi>

On Fri, 19 Sep 2008, Ivan Vecera wrote:

> ---
>  drivers/net/r8169.c |   74 ++++++++++++++++++++++++++++++++++++++++++++++++++-
>  1 files changed, 73 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index befc927..cff8dd6 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c

> +	/* MAC address is stored in EEPROM at offset 0x0e
> +	 * Realtek says: "The VPD address does not have to be a DWORD-aligned
> +	 * address as defined in the PCI 2.2 Specifications, but the VPD data
> +	 * is always consecutive 4-byte data starting from the VPD address
> +	 * specified."
> +	 */
> +	if (rtl_eeprom_read(pdev, vpd_cap, 0x000e, (__le32*)&mac[0]) < 0 ||
> +	    rtl_eeprom_read(pdev, vpd_cap, 0x0012, (__le32*)&mac[4]) < 0) {
> +		dprintk("Reading MAC address from EEPROM failed\n");
> +		return;
> +	}
> +
> +	dprintk("MAC address found in EEPROM: "
> +		"%2.2x:%2.2x:%2.2x:%2.2x:%2.2x:%2.2x\n",
> +		mac[0], mac[1], mac[2], mac[3], mac[4], mac[5], mac[6]);

Aa, one more thing here, there's nowadays print_mac() and 
DECLARE_MAC_BUF() for printing MAC-addresses using %s. Since this is 
not perf-critical in anyway here, it will save some bytes when used in 
kernel-wide scale.


Reviewed-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>


-- 
 i.
---696208474-1975253372-1221948084=:16838--
