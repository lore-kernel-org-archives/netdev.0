From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/2] Add a matching set of device_ functions for determining
 mac/phy
Date: Wed, 12 Aug 2015 15:13:56 -0700
Message-ID: <55CBC524.4070101@gmail.com>
References: <1439417187-21411-1-git-send-email-jeremy.linton@arm.com> <1439417187-21411-2-git-send-email-jeremy.linton@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@shawell.net, netdev@vger.kernel.org,
	rafael.j.wysocki@intel.com, Suravee.Suthikulpanit@amd.com,
	Catalin.Marinas@arm.com, grant.likely@linaro.org
To: Jeremy Linton <jeremy.linton@arm.com>,
	linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35219 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750953AbbHLWQK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 18:16:10 -0400
Received: by pacgr6 with SMTP id gr6so23032976pac.2
        for <netdev@vger.kernel.org>; Wed, 12 Aug 2015 15:16:09 -0700 (PDT)
In-Reply-To: <1439417187-21411-2-git-send-email-jeremy.linton@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/08/15 15:06, Jeremy Linton wrote:
> OF has some helper functions for parsing MAC and PHY settings.
> In cases where the platform is providing this information rather
> than the device itself, there needs to be similar functions for ACPI.
> 
> These functions are slightly modified versions of the ones in
> of_net which can use information provided via DT or ACPI.
> 
> Signed-off-by: Jeremy Linton <jeremy.linton@arm.com>
> ---

[snip]

> +
> +static void *device_get_mac_addr(struct device *dev,
> +				 const char *name, char *addr,
> +				 int alen)
> +{
> +	int ret = device_property_read_u8_array(dev, name, addr, alen);
> +
> +	if (ret == 0 && is_valid_ether_addr(addr))
> +		return addr;
> +	return NULL;

The DT counterpart has an additional check on the properly length to be
ETH_ALEN, you might want to have such check here for consistency and
correctness.

Other than that, this looks good to me.
-- 
Florian
