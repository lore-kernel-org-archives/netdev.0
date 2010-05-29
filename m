From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] bnx2: Fix IRQ failures during kdump.
Date: Sat, 29 May 2010 09:22:07 -0700
Message-ID: <C27F8246C663564A84BB7AB3439772421B78147573@IRVEXCHCCR01.corp.ad.broadcom.com>
References: <20100528.235052.241451895.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: "'David Miller'" <davem@davemloft.net>,
	"grundler@parisc-linux.org" <grundler@parisc-linux.org>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20100528.235052.241451895.davem@davemloft.net>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:

>
> The generic PCI layer very well can turn off MSI on all devices
> when it starts up or a device is plugged in.
>
> That's all he is doing.
>
> Drivers essentially expect that the device comes up in INTX mode
> when the driver probes the device.  All his change is doing
> is forcing that to be true, and there is no reason the generic
> PCI code can't do that.
>

I think there may be more issues after thinking about it some more.
The device is essentially still active at this time.  The PCI
layer can turn off certain things, but enabling INTX can lead to
"irq x: nobody cared" if the driver is not ready for it.  The
device really needs to be reset by the driver to be totally
reliable.
