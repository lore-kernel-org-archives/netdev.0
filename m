From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: e1000 packet corruption problem
Date: Tue, 29 Mar 2005 08:02:46 -0800
Message-ID: <C925F8B43D79CC49ACD0601FB68FF50C03793405@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "Michal Vanco" <vanco@satro.sk>, <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>I have 4-port Intel e1000 card in my dual Amd Opteron machine:
>0000:02:04.0 Ethernet controller: Intel Corp. 82540EM Gigabit Ethernet
>Controller (rev 02)
>0000:02:05.0 Ethernet controller: Intel Corp. 82540EM Gigabit Ethernet
>Controller (rev 02)
>0000:02:06.0 Ethernet controller: Intel Corp. 82540EM Gigabit Ethernet
>Controller (rev 02)
>0000:02:07.0 Ethernet controller: Intel Corp. 82540EM Gigabit Ethernet
>Controller (rev 02)
>
>with this driver:
>Intel(R) PRO/1000 Network Driver - version 5.7.6
>Copyright (c) 1999-2004 Intel Corporation.

Standard questions: what kernel version, what exact machine (and bios),
lspci -n will help here.

You might be having interrupt routing problems, have you tried
pci=noapic as a boot parameter?

The data corruption is puzzling.

>eth3 is autonegotiated at 100 Mbps FDX.
>
>Trying to forward packets through eth3 causes corruption of packets.
>I've got 'Corrupted MAC on input' trying to download (or copy)
something
>using scp. Using ftp doesn't emit any error, but all files downloaded
>are apparently corrupted.
>
>After that I've tried to disable all off-loading. In this case no error
>is visible but all download stalls forever.

How did you disable all offloading? With ethtool? Did you disable TSO
and TX/RX checksumming?  You left scatter gather on, right?

>Is this problem related only to e1000 driver or any GigE cards? Is
there
>any fix available?

Can you try the card in another (non opteron) machine?  Does your
opteron machine pci bus support PCI-X/133?

If we can reproduce this we can likely get a fix, but without a
reproduction its unlikely because we haven't seen problems like this
around here.

Jesse
