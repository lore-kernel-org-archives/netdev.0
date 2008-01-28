From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: [Bugme-new] [Bug 9836] New: e1000 network driver doesn't recognize (and load on) its hardware
Date: Mon, 28 Jan 2008 14:23:00 -0800
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F5204481F7C@orsmsx418.amr.corp.intel.com>
References: <bug-9836-10286@http.bugzilla.kernel.org/> <20080128134404.24c80ce7.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <bugme-daemon@bugzilla.kernel.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	<t.artem@mailcity.com>
To: "Andrew Morton" <akpm@linux-foundation.org>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:45132 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763493AbYA1WYK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2008 17:24:10 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20080128134404.24c80ce7.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> On Mon, 28 Jan 2008 05:32:00 -0800 (PST)
> bugme-daemon@bugzilla.kernel.org wrote:
> 
>> http://bugzilla.kernel.org/show_bug.cgi?id=9836
>> Problem Description: recently e1000 network drivers stopped working
>> when right after switching on or rebooting our Intel server. While
>> trying to 'modprobe e1000; ifconfig eth0 IP_address' I've got a
>> failure and e1000 says hardware is not detected. After about a
>> *hundred* attempts to modprobe and rmmod it, the e1000 network
>> driver finally loads and allows to set up networking. 

I'm not sure how you figured out rmmod/insmoding the driver gets you
working, but I don't see any failure messages in the dmesg log you sent,
I just see:

Intel(R) PRO/1000 Network Driver - version 7.3.20-k2-NAPI
Copyright (c) 1999-2006 Intel Corporation.
ACPI: PCI Interrupt 0000:07:04.0[A] -> GSI 16 (level, low) -> IRQ 16
e1000: 0000:07:04.0: e1000_probe: (PCI:33MHz:32-bit) 00:04:23:cc:82:5e
e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
ACPI: PCI interrupt for device 0000:07:04.0 disabled
Intel(R) PRO/1000 Network Driver - version 7.3.20-k2-NAPI
Copyright (c) 1999-2006 Intel Corporation.
ACPI: PCI Interrupt 0000:07:04.0[A] -> GSI 16 (level, low) -> IRQ 16
e1000: 0000:07:04.0: e1000_probe: (PCI:33MHz:32-bit) 00:04:23:cc:82:5e
e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
ACPI: PCI interrupt for device 0000:07:04.0 disabled
Intel(R) PRO/1000 Network Driver - version 7.3.20-k2-NAPI
Copyright (c) 1999-2006 Intel Corporation.
ACPI: PCI Interrupt 0000:07:04.0[A] -> GSI 16 (level, low) -> IRQ 16
e1000: 0000:07:04.0: e1000_probe: (PCI:33MHz:32-bit) 00:04:23:cc:82:5e
e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
e1000: eth0: e1000_watchdog: NIC Link is Up 100 Mbps Full Duplex, Flow
Control: RX/TX

I believe the PCI interrupt for device 7:4.0 disabled is you unloading
the driver again each time, and I don't see any messages at all that
indicate the driver knows anything is wrong.

can you run 'ethtool -t eth0 offline' after rebooting, loading the
module, ifconfig eth0 up, and waiting 4 seconds?

what does ethtool eth0 say after loading the driver (before you ifconfig
up it?)  are you sure you're not having some udev problem?  Can you send
the console output or attach it to the bug?

>> Steps to reproduce: reboot or power on your server. Try to up the
>> network which is attached to your Intel PCI-X Pro 1000 NIC.

This is a PCI only adapter, FYI.

>> 
> 
> Odd.

agreed, something doesn't add up here, yet.
