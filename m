From: Martin Wilck <martin.wilck@fujitsu-siemens.com>
Subject: SIOCGIFMAP silently broken?
Date: Mon, 31 Jan 2005 15:57:09 +0100
Message-ID: <41FE4745.4020003@fujitsu-siemens.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261226AbVAaO5d@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

we are using a server management software that uses the irq information
returned by the SIOCGIFMAP ioctl to correlate network interfaces with
LAN hardware.

The code for SIOCGIFMAP if net/core/dev.c simply returns netdev->irq 
which isn't set by most actual LAN drivers any more, and it seems to
be common opinion that setting netdev->irq is either optional or even 
wrong (http://www.ussg.iu.edu/hypermail/linux/kernel/0407.3/1292.html).

Consequently, the SIOCGIFMAP ioctl reports bogus IRQ values for most 
hardware; it is therefore unreliable.

Would it be possible to fix the ioctl such that it returns the correct 
irq value, e.g. be using the irq field of the associated struct pci_dev?

If not, I'd consider it better to deprecate netdev->irq officially and 
always return bogus so that people stop using it.

In both cases, the netdev->irq field isn't used anymore; perhaps it 
should be officially deprecated and/or removed?

Regards
Martin

-- 
Martin Wilck                Phone: +49 5251 8 15113
Fujitsu Siemens Computers   Fax:   +49 5251 8 20409
Heinz-Nixdorf-Ring 1        mailto:Martin.Wilck@Fujitsu-Siemens.com
D-33106 Paderborn           http://www.fujitsu-siemens.com/primergy
