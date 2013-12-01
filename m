From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] PCI / tg3: Give up chip reset and carrier loss
 handling if PCI device is not present
Date: Sun, 1 Dec 2013 12:39:19 -0800
Message-ID: <1385930359.6988.7.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <7807315.7cU9KldDtM@vostro.rjw.lan>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	"Linux PM list" <linux-pm@vger.kernel.org>,
	"Linux PCI" <linux-pci@vger.kernel.org>,
	"Bjorn Helgaas" <bhelgaas@google.com>,
	"Nithin Nayak Sujir" <nsujir@broadcom.com>,
	"David Miller" <davem@davemloft.net>
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7807315.7cU9KldDtM@vostro.rjw.lan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2013-12-01 at 02:34 +0100, Rafael J. Wysocki wrote:
> From: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> 
> Modify tg3_chip_reset() and tg3_close() to check if the PCI network
> adapter device is accessible at all in order to skip poking it or
> trying to handle a carrier loss in vain when that's not the case.
> Introduce a special PCI helper function pci_device_is_present()
> for this purpose.
> 
> Of course, this uncovers the lack of the appropriate RTNL locking
> in tg3_suspend() and tg3_resume(), so add that locking in there
> too.
> 
> These changes prevent tg3 from burning a CPU at 100% load level for
> solid several seconds after the Thunderbolt link is disconnected from
> a Matrox DS1 docking station. 

I'm not familiar with the DS1.  Does the tg3 device get removed through
tg3_remove_one() in this case?  What happens when you reconnect the DS1?
