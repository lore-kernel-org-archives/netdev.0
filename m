From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Acer Aspire 1524WLMi and RealTek 8169 - very slow
Date: Sun, 21 Nov 2004 21:58:14 +0100
Message-ID: <20041121205814.GA22460@electric-eye.fr.zoreil.com>
References: <41A09541.5040405@phekda.gotadsl.co.uk> <41A0F0D5.9050702@phekda.gotadsl.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Richard Dawe <rich@phekda.gotadsl.co.uk>
Content-Disposition: inline
In-Reply-To: <41A0F0D5.9050702@phekda.gotadsl.co.uk>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Richard Dawe <rich@phekda.gotadsl.co.uk> :
[...]
> I've got it working with 10Mbps full-duplex now. Here are the lines from 
> modprobe.conf:
> 
>   alias eth0 r8169
>   options eth0 use_dac=0 media=0x2

It makes sense. use_dac=1 is reported to badly fail on amd64 most of
time.

Can you try 2.6.10-rc2 +
http://www.kernel.org/pub/linux/kernel/people/jgarzik/patchkits/2.6/2.6.10-rc2-netdev1.patch.bz2 +
http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.10-rc2-mm1/r8169-250.patch +
http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.10-rc2-mm1/r8169-255.patch

Is it an option for you to disable ACPI, remove the media specification
and simply issue an 'ethtool eth0' a few tens of seconds after insertion
of the module ?

It takes ages to negotiate here (Netgear switch + 8169 PCI adapter).

[...]
> I tried to build version 2.2 of the driver from RealTek 
> <http://www.realtek.com.tw/> but that fails, because it uses 
> pci_dma_sync_single(), which now appears to have been split into 
> pci_dma_sync_single_for_cpu() and pci_dma_sync_single_for_device().

This version of the driver is only maintained by Realtek and bears
moderate ressemblance to the version of the driver available in the
kernel. The version number do not match.

Thanks for the get_drvinfo fix btw. Good catch.

--
Ueimor
