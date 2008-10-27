From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: RE: [PATCH] [PCI] move ICHx GbE NVM write-protection from e1000e to
 PCI quirk
Date: Mon, 27 Oct 2008 13:26:11 -0700
Message-ID: <B27EBC40D200ED48A3F4CC2EBEABAE0B20B38046@orsmsx501.amr.corp.intel.com>
References: <20081025011358.9975.77556.stgit@gitlost.lost>
 <9929d2390810241827o4b0f525dt1e34b4f17ddad4a6@mail.gmail.com>
 <490282FE.9040602@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"jbarnes@virtuousgeek.org" <jbarnes@virtuousgeek.org>
To: Jeff Garzik <jeff@garzik.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <490282FE.9040602@garzik.org>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> This PCI quirk is put in ./drivers/net/e1000e in order to share
>> defines and structs found in the driver source, and is only applicable
>> to ICHx GbE LOMs supported by that driver anyway.
>
>Seems to be it is not difficult to put it into drivers/pci/quirks.c,
>where it belongs.
>
>	Jeff

Yes, it wouldn't be difficult to put it elsewhere but does it really belong in drivers/pci/quirks.c?  The quirk is applicable only to the GbE LOM found on Intel ICH8/9/10-based platforms so one could argue it should be in arch-specific code (arch/x86/pci/fixup.c).  OTOH, quirks in driver directories are not unprecedented (e.g. drivers/clocksource/acpi_pm.c, drivers/usb/host/pci-quirks.c).  I patched it into the driver's directory as it would be an obvious reminder when adding support for future parts
to check whether the quirk is applicable and update the list of devices accordingly.

So, what is the "right" place?
