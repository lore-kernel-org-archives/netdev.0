From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/3] net: Add Keystone NetCP ethernet driver support
Date: Thu, 21 Aug 2014 16:36:12 -0700 (PDT)
Message-ID: <20140821.163612.282672926741753926.davem@davemloft.net>
References: <1408115562-22487-1-git-send-email-santosh.shilimkar@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, robh+dt@kernel.org,
	grant.likely@linaro.org, devicetree@vger.kernel.org,
	sandeep_n@ti.com
To: santosh.shilimkar@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1408115562-22487-1-git-send-email-santosh.shilimkar@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Date: Fri, 15 Aug 2014 11:12:39 -0400

> Update version after incorporating David Miller's comment from earlier
> posting [1]. I would like to get these merged for upcoming 3.18 merge
> window if there are no concerns on this version.
> 
> The network coprocessor (NetCP) is a hardware accelerator that processes
> Ethernet packets. NetCP has a gigabit Ethernet (GbE) subsystem with a ethernet
> switch sub-module to send and receive packets. NetCP also includes a packet
> accelerator (PA) module to perform packet classification operations such as
> header matching, and packet modification operations such as checksum
> generation. NetCP can also optionally include a Security Accelerator(SA)
> capable of performing IPSec operations on ingress/egress packets.
>     
> Keystone SoC's also have a 10 Gigabit Ethernet Subsystem (XGbE) which
> includes a 3-port Ethernet switch sub-module capable of 10Gb/s and
> 1Gb/s rates per Ethernet port.
>     
> NetCP driver has a plug-in module architecture where each of the NetCP
> sub-modules exist as a loadable kernel module which plug in to the netcp
> core. These sub-modules are represented as "netcp-devices" in the dts
> bindings. It is mandatory to have the ethernet switch sub-module for
> the ethernet interface to be operational. Any other sub-module like the
> PA is optional.
> 
> Both GBE and XGBE network processors supported using common driver. It
> is also designed to handle future variants of NetCP.

I don't want to see an offload driver that doesn't plug into the existing
generic frameworks for configuration et al.

If no existing facility exists to support what you need, you must work
with the upstream maintainers to design and create one.

It is absolutely no reasonable for every "switch on a chip" driver to
export it's own configuration knob, we need a standard interface all
such drivers will plug into and provide.
