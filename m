From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 2.6.11 4/8] tg3: Add msi test
Date: Tue, 22 Mar 2005 14:07:13 -0800
Message-ID: <B1508D50A0692F42B217C22C02D84972020F3E2E@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Content-class: urn:content-classes:message
To: "Jeff Garzik" <jgarzik@pobox.com>, "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"Jeff Garzik" wrote:

> Michael Chan wrote:
> > Add an MSI test to make sure MSI is working at the system level. If 
> > the test fails, the driver will go back to INTx mode.
> > 
> > Signed-off-by: Michael Chan <mchan@broadcom.com
> 
> In theory, this patch is not necessary.
> 
> pci_enable_msi() should fail, if MSI is not available at the 
> system level.
> 
> What behavior are you seeing?
> 
> 	Jeff
> 
 
Some older chipsets/APICs in older PCI machines do not properly support MSI.
In some cases you will get no interrupts and in a few cases you can get
SERR/NMI because the MSI cycle terminates abnormally. The pci_msi_quirk does
not cover all problem chipsets out there. pci_enable_msi() can succeed on
these problem machines.

Most newer PCI Express machines have no problem with MSI, but we have at
least one machine in the lab that doesn't work with MSI.

The interrupt test code is very small and can conclusively determine if MSI
is working on the machine or not. The code can later be used as part of the
ethtool self test. Without the test, we'll have to resort of a parameter or a
config option to disable MSI in tg3.

Michael
