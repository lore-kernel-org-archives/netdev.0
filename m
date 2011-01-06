From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: via-velocity: corrupted mac, deadlock on link
Date: Thu, 6 Jan 2011 12:58:22 -0800
Message-ID: <20110106125822.70a85e0a@nehalam>
References: <AANLkTi=SV=_s3ViveEX4e2FpEGKK+w6BiGs=QYCsgPsv@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Janne Karhunen <janne.karhunen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46103 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752385Ab1AFU6Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jan 2011 15:58:25 -0500
In-Reply-To: <AANLkTi=SV=_s3ViveEX4e2FpEGKK+w6BiGs=QYCsgPsv@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 6 Jan 2011 13:42:03 +0200
Janne Karhunen <janne.karhunen@gmail.com> wrote:

> Hey,
> 
> Just got my hands on via-velocity pci-e card and tried to give it
> a go on new Asus Nvidia Ion2 board. Driver loads fine and everything
> seems good until device gets a link - kernel deadlocks instantly. During
> bootup hang seems to happen when persistent-net rules rename device
> to eth1, after bootup instantly when cable is plugged (first interrupt?).
> 
> Any other quick suggestions other than to throw it away as DOA?
> 
> Linux rivendell 2.6.35-23-generic #41-Ubuntu SMP Wed Nov 24 10:18:49
> UTC 2010 i686 GNU/Linux
> 
> eth1      Link encap:Ethernet  HWaddr 00:00:00:00:00:04  (??????????)
> 
> [    1.171890] eth0: VIA Networking Velocity Family Gigabit Ethernet Adapter
> [   18.468029] via-velocity 0000:0b:00.0: BAR 0: set to [io
> 0xe800-0xe8ff] (PCI address [0xe800-0xe8ff]
> [   18.468048] via-velocity 0000:0b:00.0: BAR 1: set to [mem
> 0xfbfffc00-0xfbfffcff 64bit] (PCI address [0xfbfffc00-0xfbfffcff]
> 
> 0b:00.0 Ethernet controller: VIA Technologies, Inc.
> VT6120/VT6121/VT6122 Gigabit Ethernet Adapter (rev 82)
> 
>  16:          0          0          0          0   IO-APIC-fasteoi
> uhci_hcd:usb5
>  17:          0          0          0          0   IO-APIC-fasteoi   eth1
>  18:       4639       4703       4637       4690   IO-APIC-fasteoi
> uhci_hcd:usb4, ahci, hda_intel, nvidia
>  19:          0          0          0          1   IO-APIC-fasteoi
> uhci_hcd:usb3, xhci_hcd:usb6
>  23:      14772      14895      14872      14730   IO-APIC-fasteoi
> ehci_hcd:usb1, uhci_hcd:usb2
>  40:          0          0          0          0   PCI-MSI-edge      pciehp
>  41:          0          0          0          0   PCI-MSI-edge      pciehp
>  42:          0          0          0          0   PCI-MSI-edge      pciehp
>  43:          0          0          0          0   PCI-MSI-edge      pciehp
>  52:      10951      10844      10829      10926   PCI-MSI-edge      eth0

To debug, remove the udev rule that does renaming
  cd /lib/udev
  mkdir save; mv rules.d/75-persistent-net-generator-rules save
and remove any rules
  rm /etc/udev/70-persistent-net.rules

Then after bootup you can debug problem.
