From: Steve.Glendinning@smsc.com
Subject: Re: [Uclinux-dist-devel] [PATCH 01/01] smsc911x: fix MAC addresssetting
 after reset
Date: Thu, 5 Jun 2008 10:47:00 +0100
Message-ID: <OF45087A0F.05ABBB48-ON8025745F.00349549-8025745F.0035BEBE@smsc.com>
References: <48451668.1060407@tqs.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org
To: Jens Gehrlein <sew_s@tqs.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:1283 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753741AbYFEJrS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jun 2008 05:47:18 -0400
In-Reply-To: <48451668.1060407@tqs.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jens,

> Sorry. Newbie question:
> How can I pass the MAC address via kernel command line for this driver? 
> Is there a predefined parameter?
> My problem is:
> U-Boot resets the chip after each completed transfer. Wolfgang Denk 
> suggested to pass the MAC address via kernel command line. I need the 
> ethernet device at kernel startup to mount a root filesystem via NFS, so 

> I added the platform device in my board specific code as shown below (it 

> still relates to the old driver).
> Should I patch the driver directly to get the MAC address via __setup()
> or can I pass the MAC address via the device structures.
> 
> What do you suggest?

The smsc911x driver accepts mac addresses set "by configuration", so if 
brought up after boot you could assign the mac address like this:

ifconfig eth0 hw ether 00:11:22:33:44:55 up

But as you're using an NFS root, you need to assign the mac address during 
boot.  I'm not sure of the best way to do this, there isn't currently a 
dev_addr field in smsc911x_platform_config, but you could add one.

Alternatively, if the bootloader already sets the mac address you could 
modify the driver to read it off the device (into dev->dev_addr) before 
resetting it?

Regards,
--
Steve Glendinning
SMSC GmbH
m: +44 777 933 9124
e: steve.glendinning@smsc.com


