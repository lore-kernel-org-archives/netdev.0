From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.11 4/8] tg3: Add msi test
Date: Tue, 22 Mar 2005 17:14:58 -0500
Message-ID: <424098E2.6090007@pobox.com>
References: <B1508D50A0692F42B217C22C02D84972020F3E2E@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
To: Michael Chan <mchan@broadcom.com>
In-Reply-To: <B1508D50A0692F42B217C22C02D84972020F3E2E@NT-IRVA-0741.brcm.ad.broadcom.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Michael Chan wrote:
> Some older chipsets/APICs in older PCI machines do not properly support MSI.
> In some cases you will get no interrupts and in a few cases you can get
> SERR/NMI because the MSI cycle terminates abnormally. The pci_msi_quirk does
> not cover all problem chipsets out there. pci_enable_msi() can succeed on
> these problem machines.
> 
> Most newer PCI Express machines have no problem with MSI, but we have at
> least one machine in the lab that doesn't work with MSI.
> 
> The interrupt test code is very small and can conclusively determine if MSI
> is working on the machine or not. The code can later be used as part of the
> ethtool self test. Without the test, we'll have to resort of a parameter or a
> config option to disable MSI in tg3.


OK, so this is not a tg3-related problem at all.

It really sounds like you should update pci_msi_quirk() to cover the 
other affected cases.

I also disagree that a tg3 config option is needed, if the tg3 MSI test 
is not present.  An option to globally disable PCI MSI in the kernel is 
the preferred approach, if such an option doesn't already exist.

	Jeff
