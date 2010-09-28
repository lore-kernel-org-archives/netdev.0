From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] Add Qualcomm Gobi 2000 driver.
Date: Tue, 28 Sep 2010 11:11:40 -0700
Message-ID: <1285697500.1866.100.camel@Joe-Laptop>
References: <20100928171026.GB6083@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dbrownell@users.sourceforge.net,
	mjg59@srcf.ucam.org, jglasgow@google.com, msb@google.com,
	olofj@google.com
To: Elly Jones <ellyjones@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2499 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755864Ab0I1SLm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Sep 2010 14:11:42 -0400
In-Reply-To: <20100928171026.GB6083@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-09-28 at 13:10 -0400, Elly Jones wrote:
> From: Elizabeth Jones <ellyjones@google.com>

Hi.

The readme is out of date and should be updated.

[]

> +#if LINUX_VERSION_CODE > KERNEL_VERSION(2,6,23)
> +	usbnet = usb_get_intfdata(iface);
> +#else
> +	usbnet = iface->dev.platform_data;
> +#endif

I think it's not particularly useful to include support
for versions < current when this driver is added.

[]

> +#define DBG(format, arg...) \
> +	if (debug == 1) { \
> +		printk(KERN_INFO "QCUSBNet2k::%s " format, __FUNCTION__, ## arg); \
> +	}

This should be surrounded by a do {} while(0)

#define DBG(fmt, arg...)							\
do {										\
	if (debug == 1)								\
		printk(KERN_INFO "QCUSBNet2k::%s " fmt, __func__, ##arg);	\
} while (0)

I think many of these DBG messages should
not use DBG but the more normal pr_<level>,
dev_<level> or netdev_<level> so generally
useful messages are logged without getting
all the debugging messages.


