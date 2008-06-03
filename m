From: Jens Gehrlein <sew_s@tqs.de>
Subject: Re: [Uclinux-dist-devel] [PATCH 01/01] smsc911x: fix MAC addresssetting
 after reset
Date: Tue, 03 Jun 2008 12:01:12 +0200
Message-ID: <48451668.1060407@tqs.de>
References: <OF35F08D73.56884FA4-ON8025744E.0047900A-8025744E.0047BBC0@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Steve.Glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tqs.de ([62.157.136.17]:15500 "EHLO mail.tqs.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750971AbYFCKB1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jun 2008 06:01:27 -0400
In-Reply-To: <OF35F08D73.56884FA4-ON8025744E.0047900A-8025744E.0047BBC0@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Steve,

Steve.Glendinning@smsc.com schrieb:
>> If the MAC address has been set externally (e. g. by the bootloader
>> or via command line), this setting is lost. This patch fixes the
>> problem by always setting the saved MAC address after soft reset.

Sorry. Newbie question:
How can I pass the MAC address via kernel command line for this driver? 
Is there a predefined parameter?
My problem is:
U-Boot resets the chip after each completed transfer. Wolfgang Denk 
suggested to pass the MAC address via kernel command line. I need the 
ethernet device at kernel startup to mount a root filesystem via NFS, so 
I added the platform device in my board specific code as shown below (it 
still relates to the old driver).
Should I patch the driver directly to get the MAC address via __setup()
or can I pass the MAC address via the device structures.

What do you suggest?

Thanks and best regards
Jens
-- 

static struct resource smc911x_resources[] = {
	[0] = {
		.start		= CS4_BASE_ADDR,
		.end		= CS4_BASE_ADDR + 0xFF,
		.flags		= IORESOURCE_MEM,
	},
	[1] = {
		.start		= MXC_GPIO_BASE + 4,
		.end		= MXC_GPIO_BASE + 4,
		.flags		= IORESOURCE_IRQ,
	},
};

static struct platform_device smc911x_device = {
	.name		= "smc911x",
	.id		= 0,
	.num_resources	= ARRAY_SIZE(smc911x_resources),
	.resource	= smc911x_resources,
};

static struct platform_device *myboard_devices[] __initdata = {
	&smc911x_device,
};


static int __init <myboard>_devices_setup(void)
{
	return platform_add_devices(myboard_devices, ARRAY_SIZE(myboard_devices));
}
device_initcall(myboard_devices_setup);


