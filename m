From: Christer Weinigel <christer@weinigel.se>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Thu, 12 Mar 2009 11:41:24 +0100
Message-ID: <49B8E6D4.2030702@weinigel.se>
References: <1236738549-16703-1-git-send-email-yanok@emcraft.com>	<20090310211841.388619ca@nehalam>	<20090311084430.GU425@pengutronix.de>	<20090311.014957.117115597.davem@davemloft.net>	<49B82566.3070909@weinigel.se> <20090311171354.04c7a63d@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, s.hauer@pengutronix.de,
	yanok@emcraft.com, linux-arm-kernel@lists.arm.linux.org.uk,
	netdev@vger.kernel.org, wd@denx.de, dzu@denx.de
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 2-1-3-15a.ens.sth.bostream.se ([82.182.31.214]:33294 "EHLO
	zoo.weinigel.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754225AbZCLKl1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 06:41:27 -0400
In-Reply-To: <20090311171354.04c7a63d@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Wed, 11 Mar 2009 21:56:06 +0100
> Christer Weinigel <christer@weinigel.se> wrote:
>> It's still a pain to have to do this.  Many embedded systems that I =
have=20
>> seen have a bootloader which I can't modify to do that, but the=20
>> bootloader allows me to save the kernel command line into some kind =
of=20
>> volatile storage.  S=C3=A5 being able to set the MAC address with a:
>>
>>      setenv cmdline foo.hwaddr=3D00:de:ad:be:ef:ed
>>
>> is very nice because it allows me to use a NFS root without having t=
o=20
>> jump through hoops with initrds an such.
>>
>> Actually, I wish we had a generic way of doing that, so that could s=
et=20
>> the mac address of any ethernet interface from the kernel command in=
 a=20
>> nice and supported way.
>=20
> The problem is that usually users end up with all devices with the
> same address, unless there is some other procedure to hand out addres=
ses
> during configuration. That is why the random_ether_addr is safer.

Random mac addresses, yuk! :-)  I'd much rather have something that I=20
can make "do the right thing" than something I can't.  And as I said,=20
what I've encountered many times is a reference board from some=20
manufacturer where the following conditions are present:

1. The bootloader can pass a command line to the kernel and it is saved=
=20
in non-volatile storage that can be changed from the bootloader

2. I can not modify the bootloader

3. I can modify the Linux kernel

4. The manufacturer has hardcoded a MAC address in the ethernet driver

5. I want to use NFS root to make it easy to develop on the platform

6. We get a second board so the hardcoded MAC addresses collide

In this situation I usually hack a hwaddr module param into the etherne=
t=20
driver, so that I can actually make the devices have different, but=20
stable, MAC addresses.  The alternatives are to hardcode the MAC addres=
s=20
into the kernel and run different kernels on different boards, or to=20
create an initrd with a tools that parses the kernel command line to=20
extract the MAC address and then do ifconfig eth0 hwaddr $HWADDR, and=20
then add a DCHP client which gets the NFS root from the DCHP response=20
and finally mounts the NFS root and switches too it.  But I'm lazy so a=
s=20
I said usually just hack the driver.

    /Christer
