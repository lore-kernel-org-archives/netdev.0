From: Jens Gehrlein <sew_s@tqs.de>
Subject: Re: [Uclinux-dist-devel] [PATCH 01/01] smsc911x: fix MAC addresssetting
 after reset
Date: Thu, 05 Jun 2008 12:23:35 +0200
Message-ID: <4847BEA7.4050403@tqs.de>
References: <OF45087A0F.05ABBB48-ON8025745F.00349549-8025745F.0035BEBE@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Steve.Glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tqs.de ([62.157.136.17]:15252 "EHLO mail.tqs.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754717AbYFEKXf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jun 2008 06:23:35 -0400
In-Reply-To: <OF45087A0F.05ABBB48-ON8025745F.00349549-8025745F.0035BEBE@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Steve,

Steve.Glendinning@smsc.com schrieb:
> Hi Jens,
> 
>> Sorry. Newbie question:
>> How can I pass the MAC address via kernel command line for this driver? 
>> Is there a predefined parameter?
>> My problem is:
>> U-Boot resets the chip after each completed transfer. Wolfgang Denk 
>> suggested to pass the MAC address via kernel command line. I need the 
>> ethernet device at kernel startup to mount a root filesystem via NFS, so 
> 
>> I added the platform device in my board specific code as shown below (it 
> 
>> still relates to the old driver).
>> Should I patch the driver directly to get the MAC address via __setup()
>> or can I pass the MAC address via the device structures.
>>
>> What do you suggest?
> 
> The smsc911x driver accepts mac addresses set "by configuration", so if 
> brought up after boot you could assign the mac address like this:
> 
> ifconfig eth0 hw ether 00:11:22:33:44:55 up
> 
> But as you're using an NFS root, you need to assign the mac address during 
> boot.  I'm not sure of the best way to do this, there isn't currently a 
> dev_addr field in smsc911x_platform_config, but you could add one.
> 
> Alternatively, if the bootloader already sets the mac address you could 
> modify the driver to read it off the device (into dev->dev_addr) before 
> resetting it?

My hope was, that U-Boot leaves the MAC address in the controller's 
register, but it resets the chip. We don't have an EEPROM connected to 
the controller. Unfortunately, ARM Linux doesn't provide board info 
structures or flat device tree like PowerPC Linux to pass data from the 
bootloader to the Kernel.

Additionally, I didn't succeed in compiling your new driver with Kernel 
2.6.22, because the Kernel API changed, and I can't switch to a new 
kernel. So I'm creating a private patch: getting the the MAC address 
from private kernel commmand line parameter using __setup().

However, as a suggestion for improvement of your new driver: could you 
extend the code, so that the board specific code could pass the MAC 
address via "struct platform_device", e.g. using the struct member .dev? 
Like using ifconfig it would allow multiple instances and the board 
specific code can take care, where it get the MAC addresses from.

Best regards,
Jens
