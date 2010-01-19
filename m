From: "Ha, Tristram" <Tristram.Ha@Micrel.Com>
Subject: RE: [PATCH 2.6.33 1/3] net: Micrel KSZ8841/2 PCI Ethernet driver
Date: Tue, 19 Jan 2010 13:51:58 -0800
Message-ID: <14385191E87B904DBD836449AA30269D580AA0@MORGANITE.micrel.com>
References: <14385191E87B904DBD836449AA30269D021A4A@MORGANITE.micrel.com> <e2d7436a1001160800u11206f54iaf07bb92331a256a@mail.gmail.com> <4B51E64B.6010706@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Dave Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, "Michael Buesch" <mb@bu3sch.de>,
	=?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
To: "Felix Fietkau" <nbd@openwrt.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753826Ab0ASVxp@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <4B51E64B.6010706@openwrt.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> If my assumptions are correct, then I thing it would be better to have
>> a driver that presents this device as two: one - an ethernet device,
>> and second - a switch management interface like the one used in OpenWRT.
>> 
>> Here are some links for reference:
>> http://downloads.openwrt.org/kamikaze/8.09.2/kamikaze_8.09.2_source.ta r.bz2;
>> subdir: package/switch/src/
>>   -> switch management driver for ADMTEK Adm6996 and Broadcom
>> BCM5325E/536x
> Don't look at that ;)
> The code you're referring to is just a simple hack of mine that is a few years old now. It's
> going to be removed as soon as the drivers have been ported to a proper API. 
> 
> I've been working on a switch configuration API based on netlink, which is being used on some of
> the other platforms in OpenWrt. 
> 
> You can find the sources here:
> https://dev.openwrt.org/export/19173/trunk/target/linux/generic-2.6/files/drivers/net/phy/swconfig.c
> https://dev.openwrt.org/export/19173/trunk/target/linux/generic-2.6/files/include/linux/switch.h
> 
> It's meant to be used with drivers that hook into the PHY abstraction layer.
> You can find an example of such a driver here:
> https://dev.openwrt.org/export/19173/trunk/target/linux/generic-2.6/files/drivers/net/phy/rtl8306.c
> 
> I'll do the final cleanups and submit it for review once I have time to do so.
> 
> - Felix

Your work looks interesting, but rtl8036 seems to use MDIO page registers to access its own internal registers.  Micrel switches do not have that feature and so cannot use that way.

I am looking at those PHY drivers and try to figure out how they work under mdio bus.  I am using Micrel's own KSZ8695P and KSZ9692P SoC to develop and debug the KSZ884X PCI driver.  KSZ9692P actually has two external PHYs so that the PHY driver can run on it.  But the driver does not load because I probably need to add some hooks to the mdio bus driver to do the actual hardware access.  Can somebody give me some pointers to this mdio bus support?  Does the PHY driver create a user interface like eth0 so that it can be accessed using some tools like ethtool?

Anyway I am afraid the phy driver model does not work on KSZ884X.  I cannot think of how the mdio bus accesses hardware registers located on a PCI device.
