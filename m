From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 3/7] net: phy: spi_ks8995: add register initialization
Date: Sun, 7 Feb 2016 20:38:25 -0800
Message-ID: <56B81BC1.6090904@gmail.com>
References: <1454884753-4560-1-git-send-email-helmut.buchsbaum@gmail.com>
 <1454884753-4560-4-git-send-email-helmut.buchsbaum@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>
To: Helmut Buchsbaum <helmut.buchsbaum@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:36408 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753979AbcBHEi2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 23:38:28 -0500
Received: by mail-ob0-f175.google.com with SMTP id ba1so138777768obb.3
        for <netdev@vger.kernel.org>; Sun, 07 Feb 2016 20:38:28 -0800 (PST)
In-Reply-To: <1454884753-4560-4-git-send-email-helmut.buchsbaum@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/02/2016 14:39, Helmut Buchsbaum wrote:
> Since several use cases need to setup at least some basic control
> registers add the ability to configure an array containing such
> register initialization values within the platform data of the switch.
> Furthermore expose this capabilty to the devicetree.
> 
> Platform data now contains a pointer to an array and the array length
> where each member contains the register to be initialized, the
> initialization value and a register mask, since in many use cases there
> is only the need to init some bits of a register, e.g. disabling unused
> ports.
> 
> The devicetree notation add the property 'settings' to the SPI node of the
> ks8985 driver, which is a list of triple values (register, value, mask),
> e.g.:
> 
> settings = <0x4D 0x08 0x08
>             0x5D 0x08 0x08>;

You encode way too much in the Device Tree that should be knowledge to
the driver on how to configure the switch. This is very tempting,
because you do not dictate any use case and let people define it based
on their Device Tree source, but at the same time, this is very error
prone and does not provide what a proper device driver needs to be doing
by defining a standard and predictable behavior.

Right now this driver is a PHY driver, but it should be moved to a DSA
driver eventually such that each port is exposed as a network interface,
and you have hooks to power on/off ports based on whether a
corresponding network interface is up/down.
