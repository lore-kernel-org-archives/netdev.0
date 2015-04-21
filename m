From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH 0/3] Enable connecting DSA-based switch to the USB
 RMII interface.
Date: Tue, 21 Apr 2015 10:46:29 -0700
Message-ID: <55368CF5.4080900@gmail.com>
References: <1429622791-7195-1-git-send-email-kaisrja1@fel.cvut.cz> <20150421124737.GD32294@lunn.ch> <55368667.5030105@gmail.com> <20150421173012.GK32294@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Jan Kaisrlik <kaisrja1@fel.cvut.cz>, sojkam1@fel.cvut.cz,
	tkonecny@retia.cz, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jan Kaisrlik <ja.kaisrlik@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150421173012.GK32294@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 21/04/15 10:30, Andrew Lunn wrote:
>> My goal in reworking this weird DSA device/driver model is that you
>> could just register your switch devices as an enhanced
>> phy_driver/spi_driver/pci_driver etc..., such that libphy-ready drivers
>> could just take advantage of that when they scan/detect their MDIO buses
>> and find a switch. We are not quite there yet, but some help could be
>> welcome, here are the WIP patches (tested with platform_driver only so far):
> 
> We are hijacking another thread, but...
> 
> I don't understand you here. Who calls dsa_switch_register()?

Any driver which is backing the underlying device, if this is a PCI(e)
switch, a pci_driver's probe function gets called, and then registers
with DSA a switch device, very much like this:

https://github.com/ffainelli/linux/commit/f94efc3d7b489955351c01efeafcc89939df388e

> 
> I know of a board coming soon which has three switch chips on
> it. There is one MDIO device in the Soc, but there is an external MDIO
> multiplexor controlled via gpio lines, such that each switch has its
> own MDIO bus. The DT binding does not support this currently, but the
> underlying data structures do.
> 
> How do you envisage dsa_switch_register() to work in such a setup?

I would envision something where we can scan all of these switches
individually using their respective device drivers, with the help of
Device Tree or platform_data, figure out which position in a
dsa_switch_tree they should have, and make sure that we create a
dsa_switch_tree which reflects that, taking probe ordering into account.
All of these switches would be phy_driver instances, like this:
https://github.com/ffainelli/linux/commit/4a5c6b17de36377f6a71423b91f80bc1c7fee7be

We can keep discussing the details in a separate thread, I think that
would be useful.
-- 
Florian
