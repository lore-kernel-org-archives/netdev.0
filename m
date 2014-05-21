From: Kevin Hilman <khilman@linaro.org>
Subject: Re: [PATCH] net: davinci_emac: fix oops caused by uninitialized ndev->dev
Date: Wed, 21 May 2014 16:39:40 -0700
Message-ID: <7h8upuog5f.fsf@paris.lan>
References: <1400580697-24994-1-git-send-email-nsekhar@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>,
	Linux DaVinci Mailing List
	<davinci-linux-open-source@linux.davincidsp.com>,
	Linux netdev Mailing List <netdev@vger.kernel.org>,
	Prabhakar Lad <prabhakar.csengg@gmail.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: Sekhar Nori <nsekhar@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:45907 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752306AbaEUXjm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2014 19:39:42 -0400
Received: by mail-pd0-f175.google.com with SMTP id z10so1850512pdj.34
        for <netdev@vger.kernel.org>; Wed, 21 May 2014 16:39:42 -0700 (PDT)
In-Reply-To: <1400580697-24994-1-git-send-email-nsekhar@ti.com> (Sekhar Nori's
	message of "Tue, 20 May 2014 15:41:37 +0530")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sekhar Nori <nsekhar@ti.com> writes:

> Commit e194312854edc22a2faf1931b3c0608fe20cb969 (drivers: net:
> davinci_cpdma: Convert kzalloc() to devm_kzalloc()) triggered
> a bug in emac_probe() wherein dev member of net_device is used
> for devres allocations even before it is initialized.
>
> This patch fixes that by using the struct device in platform_device
> instead.
>
> While at it, use &pdev->dev consistently for console messages instead
> of using ndev->dev for just one case and remove an unnecessary line
> continuation.
>
> Reported-by: Kevin Hilman <khilman@linaro.org>
> Helped-by: George Cherian <george.cherian@ti.com>
> Signed-off-by: Sekhar Nori <nsekhar@ti.com>

Tested-by: Kevin Hilman <khilman@linaro.org>

I verified this patch fixes the boot on dm365-evm (legacy boot) and
da850-evm (DT boot).

Thanks,

Kevin
