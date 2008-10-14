From: Gernot Hillier <gernot.hillier@siemens.com>
Subject: Re: e1000e: sporadic "hardware error"s with Intel 82563EB on Supermicro
 X7DB3
Date: Tue, 14 Oct 2008 11:18:09 +0200
Message-ID: <48F463D1.70605@siemens.com>
References: <EA929A9653AAE14F841771FB1DE5A1365F498F4EDC@rrsmsx501.amr.corp.intel.com> <E3627BC91D010645BD262A1E8720005106A64162@orsmsx420.amr.corp.intel.com> <48EE04C0.6070504@siemens.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Hockert, Jeff W" <jeff.w.hockert@intel.com>
To: "Graham, David" <david.graham@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from david.siemens.de ([192.35.17.14]:20074 "EHLO david.siemens.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753077AbYJNJSc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Oct 2008 05:18:32 -0400
In-Reply-To: <48EE04C0.6070504@siemens.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave!

Sorry for the delay (and the self-follow-up), but now I can hopefully
provide answers to all your questions...

Hillier, Gernot wrote:
> However, one detail confuses us: we can currently reproduce this problem on
> two machines. One of them is equipped with an optional IPMI card, the other
> one isn't. (The Supermicro X7DB3 doesn't include full IPMI support onboard,
> but has a "LP IPMI 2.0 (SIMLP) Slot" where you can place an optional card).

The "IPMI card" we use is a "Supermicro AOC-SIMLP-B".

Overview: http://www.supermicro.com/products/accessories/addon/sim.cfm
Manual:   http://www.supermicro.com/manuals/other/AOC-SIMLP.pdf

> The box with the IPMI card shows the hardware errors quite often (in one of
> about 200 tries) while the other box still shows the problem, but much more
> seldom (in one of >1000 tries). Now we wonder if the BMC is on the IPMI
> card or on the board itself - in the first case, I'm not sure if you thesis
> fully explains the problems we can see.

However, after digging through some manuals, I'm quite sure the BMC is
integrated in the Intel ESB2 I/O Controller Hub used on our board, not
on the IPMI card. So we should have an Intel BMC.

> And there's another detail I'd like to mention: we first found the problem
> by doing continuous reboots as originally described, but we found we can
> also reproduce it with an endless loop of "rmmod;sleep 3;modprobe". Does
> this somehow contradict with your thesis?
> 
>> There have been further improvements made to the driver synchronization
>> code since the 0.3.3.3-k2 driver, and it is possible that a newer driver
>> would resolve the issue. It'd be good for us to know if that's the case.
>> The driver version is not yet (AFAICS) upstream, but is already
>> available in the standalone e1000e-0.4.1.7 driver on sourceforge.
>> (google "sourceforge e1000e"). Would you be able to try that, as a first
>> step ? 
> 
> Yes, I did. Unfortunately, 0.4.1.7 still shows the problem - on both machines:
> 
> e1000e: Intel(R) PRO/1000 Network Driver - 0.4.1.7-NAPI
> e1000e: Copyright (c) 1999-2008 Intel Corporation.
> ACPI: PCI Interrupt 0000:06:00.0[A] -> GSI 18 (level, low) -> IRQ 18
> PCI: Setting latency timer of device 0000:06:00.0 to 64
> 0000:06:00.0: 0000:06:00.0: Hardware Error
> 0000:06:00.0: eth0: (PCI Express:2.5GB/s:Width x4) 00:30:48:66:c7:06
> 0000:06:00.0: eth0: Intel(R) PRO/1000 Network Connection
> 0000:06:00.0: eth0: MAC: 5, PHY: 5, PBA No: 2050ff-0ff
> ACPI: PCI Interrupt 0000:06:00.1[B] -> GSI 19 (level, low) -> IRQ 19
> PCI: Setting latency timer of device 0000:06:00.1 to 64
> 0000:06:00.1: eth1: (PCI Express:2.5GB/s:Width x4) 00:30:48:66:c7:07
> 0000:06:00.1: eth1: Intel(R) PRO/1000 Network Connection
> 0000:06:00.1: eth1: MAC: 5, PHY: 5, PBA No: 2050ff-0ff
> 0000:06:00.0: eth0: Hardware Error
> 0000:06:00.0: eth0: Hardware Error
> 0000:06:00.0: eth0: Hardware Error
> 0000:06:00.0: eth0: Hardware Error
> 0000:06:00.0: eth0: Hardware Error
> 
> Is there any further debug code I could add to narrow down things?
> 
>> If this does not resolve the issue for the Supermicro board, you likely
>> also require a "FW-side" fix, and this comes in one of two flavors. If
>> the board has an INTEL BMC, then we will need to update it with a new
>> BMC version. If the board has a Supermicro BMC (I expect that it does),
>> then we can provide a patch to some of the platform microcode using a
>> EEPROM update.  To determine which is appropriate for you, we'll need to
>> know more about the platform. There's probably a BMC version number on
>> one of the BIOS menus. I can work with you to find the info we need, and
>> then, to help you to perform the necessary steps to perform an upgrade. 
> 
[...]
Still no helpful contact within Supermicro, but we found the following
information in the web interface provided by the "IPMI card":

Device InformationProduct Name: Supermicro Daughter Card
Serial Number: 02969601ac46a6df
Device IP Address: 192.168.2.4
Device MAC Address: 08:15:08:15:08:15
Firmware Version: 01.59.00
Firmware Build Number: 5420
Firmware Description: Sep-29-2008-09-45-NonKVM
Hardware Revision: 0x22

The BIOS IPMI menu itself says:

IPMI Specification Version: 2.0
Firmware Version: 1.59

I hope that those details answered your questions, so that we can
proceed with your suggestions. Think we now need the "new BMC version"
you mentioned, right?

If there's anything I can test or lookup from the software side to
speedup things (like additional debugging of the driver, etc.), please
don't hesitate to ask!

--
Gernot
