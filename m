From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [1/8] mwifiex: only call mwifiex_sdio_probe_of() if dev has an OF
 node
Date: Thu, 16 Jun 2016 15:05:31 +0000 (UTC)
Message-ID: <20160616150531.8368261418@smtp.codeaurora.org>
References: <1464358702-19083-2-git-send-email-javier@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Xinming Hu <huxm@marvell.com>,
	Javier Martinez Canillas <javier@osg.samsung.com>,
	Amitkumar Karwar <akarwar@marvell.com>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	Nishant Sarmukadam <nishants@marvell.com>
To: Javier Martinez Canillas <javier@osg.samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:56798 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753900AbcFPPFh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 11:05:37 -0400
In-Reply-To: <1464358702-19083-2-git-send-email-javier@osg.samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Javier Martinez Canillas <javier@osg.samsung.com> wrote:
> SDIO is an auto enumerable bus so the SDIO devices are matched using the
> sdio_device_id table and not using compatible strings from a OF id table.
> 
> However, commit ce4f6f0c353b ("mwifiex: add platform specific wakeup
> interrupt support") allowed to match nodes defined as child of the SDIO
> host controller in the probe function using a compatible string to setup
> platform specific parameters in the DT.
> 
> The problem is that the OF parse function is always called regardless if
> the SDIO dev has an OF node associated or not, and prints an error if it
> is not found. So, on a platform that doesn't have a node for a SDIO dev,
> the following misleading error message will be printed:
> 
> [  12.480042] mwifiex_sdio mmc2:0001:1: sdio platform data not available
> 
> Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>
> Reviewed-by: Julian Calaby <julian.calaby@gmail.com>

Thanks, 8 patches applied to wireless-drivers-next.git:

6f49208fec85 mwifiex: only call mwifiex_sdio_probe_of() if dev has an OF node
cc524d1706b7 mwifiex: propagate sdio_enable_func() errno code in mwifiex_sdio_probe()
032e0f546c7e mwifiex: propagate mwifiex_add_card() errno code in mwifiex_sdio_probe()
a82f65aae143 mwifiex: consolidate mwifiex_sdio_probe() error paths
d3f04ece53a4 mwifiex: use dev_err() instead of pr_err() in mwifiex_sdio_probe()
213d9421c165 mwifiex: check if mwifiex_sdio_probe_of() fails and return error
806dd220340d mwifiex: don't print an error if an optional DT property is missing
5e94913f676a mwifiex: use better message and error code when OF node doesn't match

-- 
Sent by pwcli
https://patchwork.kernel.org/patch/9138513/
