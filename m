From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] pciaer: report config read/write errors
Date: Tue, 2 Dec 2008 11:44:41 -0800
Message-ID: <20081202114441.4389fab7@extreme>
References: <20081202004115.12058.64881.stgit@gitlost.lost>
	<20081201174754.2e5ef401@extreme>
	<20081201.232527.66213356.davem@davemloft.net>
	<20081202092316.7d6b6291@extreme>
	<493586AF.3030402@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, jeff@garzik.org,
	peter.p.waskiewicz.jr@intel.com, linux-pci@vger.kernel.org
To: Loic Prylli <loic@myri.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <493586AF.3030402@myri.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 02 Dec 2008 14:04:15 -0500
Loic Prylli <loic@myri.com> wrote:

> On 12/02/2008 12:23 PM, Stephen Hemminger wrote:
> > This patch does more error checking in the Advanced Error Reporting code.
> > Since AER needs to access PCI registers > 255, it won't work without MMCONFIG
> > and other quirks may stop it as well. The code must check this by looking
> > at return values from pci_read/write_config_XXX calls.  
> >
> > I don't have any hardware that uses AER routines but discovered this 
> > in earlier versions of the sky2 driver that tried to use
> > pci AER routines. Ended up just giving up and using other ways to access PCI
> > config space on sky2 since there were too many platform glitches.
> >   
> 
> 
> 
> 
> When experimenting with sky2 driver, was pci_find_ext_capability() 
> returning non-zero although further ext-space accesses were failing?
> 

No pci_find_ext_capability would succeed but all access to registers >= 256
would fail if MMCONFIG failed. Since the device often asserts stray errors on boot, if the
error could not be cleared, the driver would get stuck when IRQ was enabled.

P.s: you can look back into LKML for Linus discussion about why MMCONFIG
is broken anyway.
