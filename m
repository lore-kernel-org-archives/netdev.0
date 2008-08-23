From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH netdev-2.6] jme: JMicron Gigabit Ethernet Driver
 (Resend1)
Date: Sat, 23 Aug 2008 14:40:40 -0400
Message-ID: <20080823144040.08fcc322@speedy>
References: <48B04DF4.3080103@cooldavid.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Ethan <ethanhsiao@jmicron.com>,
	akeemting <akeem@jmicron.com>, netdev@vger.kernel.org
To: Guo-Fu Tseng <cooldavid@cooldavid.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:39935 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751491AbYHWSkp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Aug 2008 14:40:45 -0400
In-Reply-To: <48B04DF4.3080103@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A couple of really minor things that could be changed (but don't have to).

> +struct jme_spi_op {
> +	void __user *uwbuf;
> +	void __user *urbuf;
> +	__u8	wn;	/* Number of write actions */
> +	__u8	rn;	/* Number of read actions */
> +	__u8	bitn;	/* Number of bits per action */
> +	__u8	spd;	/* The maxim acceptable speed of controller, in MHz.*/
> +	__u8	mode;	/* CPOL, CPHA, and Duplex mode of SPI */
> +
> +	/* Internal use only */
> +	__u8	*kwbuf;
> +	__u8	*krbuf;
> +	__u8	sr;
> +	__u16	halfclk; /* Half of clock cycle calculated from spd, in ns */
> +};


The conventional usage is to use __u8 for parameters that are being used in a kernel to
user ABI interface (like ioctl), and u8 for elements in a structure in a device driver.
Not sure why there is a distinction, but that is what I learne.

> --- netdev-2.6/include/linux/pci_ids.h	2008-08-22 07:48:54.000000000 +0800
> +++ linux/include/linux/pci_ids.h	2008-08-23 01:12:07.000000000 +0800
> @@ -2224,6 +2224,8 @@
>   #define PCI_DEVICE_ID_JMICRON_JMB38X_SD	0x2381
>   #define PCI_DEVICE_ID_JMICRON_JMB38X_MMC 0x2382
>   #define PCI_DEVICE_ID_JMICRON_JMB38X_MS	0x2383
> +#define PCI_DEVICE_ID_JMICRON_JMC250	0x0250
> +#define PCI_DEVICE_ID_JMICRON_JMC260	0x0260

Most device drivers no longer add entries to pci_ids.h for each device type. This used to
be done, but the file was getting too big and the id's only get used in one place.
