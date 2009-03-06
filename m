From: Nicholas Kinar <n.kinar@usask.ca>
Subject: ENC28J60 driver causes kernel to be unresponsive
Date: Fri, 06 Mar 2009 10:17:45 -0600
Message-ID: <49B14CA9.2000400@usask.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.usask.ca ([128.233.192.40]:41251 "EHLO smtp.usask.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753043AbZCFQqb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Mar 2009 11:46:31 -0500
Received: from conversion-daemon.usask.ca by usask.ca
 (iPlanet Messaging Server 5.2 HotFix 2.18 (built Jul  3 2007))
 id <0KG300601EENNW@usask.ca> (original mail from n.kinar@usask.ca)
 for netdev@vger.kernel.org; Fri, 06 Mar 2009 10:17:46 -0600 (CST)
Received: from [128.233.99.188] (pp000fb06c0efa.usask.ca [128.233.99.188])
 by usask.ca (iPlanet Messaging Server 5.2 HotFix 2.18 (built Jul  3 2007))
 with ESMTPSA id <0KG300MBCELLF8@usask.ca> for netdev@vger.kernel.org; Fri,
 06 Mar 2009 10:17:45 -0600 (CST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello--

I am testing the new ENC28J60 SPI-to-Ethernet driver on a custom AVR32 
embedded system running  Linux.  The kernel that I am using is 
2.6.27.6.atmel.1, and I have compiled the ENC28J60 as a module.  The SPI 
setup code in my setup.c file is:

static struct spi_board_info spi1_board_info[] __initdata = {
    /*SPI Atmel dataflash*/
    {
        .modalias    = "mtd_dataflash",
        .max_speed_hz    = 8000000,
        .chip_select    = 0,
    },

    /*Ethernet controller*/
    {
        .modalias         = "enc28j60",
        .controller_data    = (void*)GPIO_PIN_PB(3),
        .mode             = SPI_MODE_0,
        .irq            = (GPIO_PIN_PB(25) + GPIO_IRQ_BASE),
        .max_speed_hz        = 20000000,
        .chip_select        = 1,   
    },
};

At runtime, I load the module via modprobe, and there are no errors 
written to the kernel log when the driver loads.  However, the behavior 
of the driver is sporadic, and the embedded system often becomes 
unresponsive when:

(1) I plug in a cross-wired Ethernet cable;
(2) I run dropbear on the embedded system and try to SSH into the 
embedded system via telnet

In the case of dropbear, when I try to SSH, the dropbear version is 
sometimes displayed on the host system's telnet terminal, but the prompt 
never appears. 

I have noticed that the current consumption of the ENC28J60 chip goes up 
(and remains up) when the kernel becomes unresponsive.  The lights on 
the Ethernet connector continue to blink.  This leads me to think that 
something is happening in a loop, and never exits from the loop.

Sometimes, I cannot ping the embedded system from the host.  The ping is 
sporadic; sometimes it works, and sometimes it does not.

I am not certain if this is a problem related to improper setup of the 
spi_board_info struct, or whether I have to change some setting using 
ethtool.  I've tried to use ethtool to change the duplex from full to 
half, but the unresponsive behavior still continues.  I've tried to 
Google for a solution to this, but I can't seem to find any setup code 
for the spi_board_info struct, or any setup information on how to use 
the ENC28J60 driver.

I searched this mailing list, and I've found some patches that have been 
submitted regarding kernel oops and problems with the ENC28J60 driver 
after entering and exiting the low power mode.

I pulled the latest version of the mainstream kernel from the kernel 
tree, but comparing the 2.6.27.6.atmel.1 version of the ENC28J60 driver 
with the version of the ENC28J60 driver in the kernel tree, I do not see 
some of the most recent patches.

Where could I download the most up-to-date version of the ENC28J60 
driver (including the patches on the mailing list)?  Could trying a 
newer version of the driver help?  Or do I need to adjust my settings 
via Ethtool?

Does the configuration of the LEDs of the ENC28J60 affect the driver 
operation?  Would I have to physically change my hardware to use the 
ENC28J60 driver?


Nicholas Kinar
n.kinar@usask.ca








