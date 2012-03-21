From: Mike Sinkovsky <msink@permonline.ru>
Subject: Re: [PATCH v2] ethernet driver for the WIZnet W5300 chip
Date: Wed, 21 Mar 2012 12:20:59 +0600
Message-ID: <4F69734B.7040105@permonline.ru>
References: <1332149037-12025-1-git-send-email-msink@permonline.ru> <1332266881.2489.4.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, msink@permonline.ru
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.ccl.ru ([195.222.140.73]:62573 "EHLO mail4.ccl.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750852Ab2CUGVO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Mar 2012 02:21:14 -0400
In-Reply-To: <1332266881.2489.4.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

21.03.2012 0:08, Ben Hutchings =D0=BD=D0=B0=D0=BF=D0=B8=D1=81=D0=B0=D0=BB=
:
> +static void w5300_get_drvinfo(struct net_device *ndev,
> +			      struct ethtool_drvinfo *info)
> +{
> +	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
> +	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
> +	strlcpy(info->fw_version, "N/A", sizeof(info->fw_version));
> [...]
>
> Nitpick: if you don't have firmware, don't set fw_version at all.
>
> Ben.

Then ethtool prints empty string as firmware version, I think "N/A" is=20
more intuitive.
Can will remove, if it is preferred way.


But I have a question to networking guru's:

This chip have FRAME_SIZE limited to 1514, including eth header.
So, for 802.1Q vlan packets mtu must be set to 1496.
=46or now we handle this from userspace, but I think this is wrong in g=
eneral
- handling hardware bugs and limitations is kernels job.

Can driver somehow limit mtu for slave vlan devices to 1496, but still=20
use 1500
for plain ethernet?
->ndo_change_mtu is called for master device only, not for it's slaves.

(and sorry for my russian english, just in case)

---
Mike
