From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] sfc: Convert to use hwmon_device_register_with_groups
Date: Thu, 28 Nov 2013 02:11:33 +0000
Message-ID: <1385604693.1586.76.camel@bwh-desktop.uk.level5networks.com>
References: <1385523187-31996-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	<lm-sensors@lm-sensors.org>
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:41534 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754667Ab3K1CLi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Nov 2013 21:11:38 -0500
In-Reply-To: <1385523187-31996-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-11-26 at 19:33 -0800, Guenter Roeck wrote:
> Simplify the code. Avoid race conditions caused by attributes
> being created after hwmon device registration. Implicitly
> (through hwmon API) add mandatory 'name' sysfs attribute.
> 
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
> ---
> Compile tested only.
[...]

Very close, but you missed this bit:

--- a/drivers/net/ethernet/sfc/mcdi_mon.c
+++ b/drivers/net/ethernet/sfc/mcdi_mon.c
@@ -142,7 +142,7 @@ static int efx_mcdi_mon_update(struct efx_nic *efx)
 static int efx_mcdi_mon_get_entry(struct device *dev, unsigned int index,
 				  efx_dword_t *entry)
 {
-	struct efx_nic *efx = dev_get_drvdata(dev);
+	struct efx_nic *efx = dev_get_drvdata(dev->parent);
 	struct efx_mcdi_mon *hwmon = efx_mcdi_mon(efx);
 	int rc;
 
---

With that addition, it works for me, and you can add my Reviewed-by.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
