From: Tabi Timur-B04825 <B04825@freescale.com>
Subject: Re: [PATCH] gianfar_ptp: use iomem, not ioports resource tree in
 probe
Date: Wed, 24 Oct 2012 17:59:38 +0000
Message-ID: <6AE080B68D46FC4BA2D2769E68D765B70810B134@039-SN2MPN1-023.039d.mgd.msft.net>
References: <1351092096-14811-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wei Yang <Wei.Yang@windriver.com>,
	Manoil Claudiu-B08782 <B08782@freescale.com>,
	Tabi Timur-B04825 <B04825@freescale.com>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe004.messaging.microsoft.com ([65.55.88.14]:59521 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934276Ab2JXR7m convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Oct 2012 13:59:42 -0400
In-Reply-To: <1351092096-14811-1-git-send-email-paul.gortmaker@windriver.com>
Content-Language: en-US
Content-ID: <A5F6A29D9A52AD478A90201828CE2472@mgd.freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 24, 2012 at 10:21 AM, Paul Gortmaker
<paul.gortmaker@windriver.com> wrote:
> From: Wei Yang <Wei.Yang@windriver.com>
>
> When using a 36 bit dtb file, the driver complains "resource busy".
>
> Investigating the source of the message leads one to the
> gianfar_ptp_probe function.
>
> Since the type of the device resource requested in this function
> is IORESOURCE_MEM, it should use "iomem_resource" instead of
> "ioports_resource".

I can't comment on this patch, since I didn't write the driver, but I
am confused on one thing.  Why is the driver using platform_xxx calls
to get data?  Why isn't it using of_xxx calls to read properties from
the device tree?  For example, why is it using

	etsects->irq = platform_get_irq(dev, 0);

to get the IRQ?  Shouldn't it do this instead:

	etsects->irq = irq_of_parse_and_map(node, 0);

-- 
Timur Tabi
Linux kernel developer at Freescale
