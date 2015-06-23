From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: Cavium: Fix MAC address setting in shutdown
 state
Date: Tue, 23 Jun 2015 07:10:13 -0700 (PDT)
Message-ID: <20150623.071013.2258233138502834064.davem@davemloft.net>
References: <052701d0ad83$c60df970$5229ec50$@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Aleksey.Makarov@caviumnetworks.com,
	sgoutham@cavium.com, thlab.kim@samsung.com, s.dyasly@samsung.com,
	robert.richter@caviumnetworks.com
To: p.fedin@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33731 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932307AbbFWN6Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 09:58:24 -0400
In-Reply-To: <052701d0ad83$c60df970$5229ec50$@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Fedin <p.fedin@samsung.com>
Date: Tue, 23 Jun 2015 10:11:03 +0300

> This bug pops up with NetworkManager on Fedora 21. NetworkManager tends to
> stop the interface (nicvf_stop() is called) before changing settings. In
> stopped state MAC cannot be sent to a PF. However, when the interface is
> restarted (nicvf_open() is called), we ping the PF using NIC_MBOX_MSG_READY
> message, and the PF replies back with old MAC address, overriding what we
> had after MAC setting from userspace. As a result, we cannot set MAC
> address using NetworkManager.
> 
> This patch introduces special tracking of MAC change in stopped state so
> that the correct new MAC address is sent to a PF when interface is reopen.
> 
> Signed-off-by: Pavel Fedin <p.fedin@samsung.com>
> ---
>  Differences from v1:
> - Fixed a couple of checkpatch.pl reports (was forgotten in v1)
> - Adjusted email client prefs, hopefully will not corrupt patches any more.

Still have problems:

> diff --git a/drivers/net/ethernet/cavium/thunder/nic.h b/drivers/net/ethernet/cavium/thunder/nic.h
> index a3b43e5..dda8a02 100755
> --- a/drivers/net/ethernet/cavium/thunder/nic.h
> +++ b/drivers/net/ethernet/cavium/thunder/nic.h
> @@ -263,6 +263,7 @@ struct nicvf {

This hunk makes 'git am' complain:

Applying: net: Cavium: Fix MAC address setting in shutdown state
warning: drivers/net/ethernet/cavium/thunder/nic.h has type 100644, expected 100755
