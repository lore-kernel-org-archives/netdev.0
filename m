From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.11 4/8] tg3: Add msi test
Date: Tue, 22 Mar 2005 17:26:44 -0500
Message-ID: <42409BA4.3090302@pobox.com>
References: <B1508D50A0692F42B217C22C02D84972020F3E2E@NT-IRVA-0741.brcm.ad.broadcom.com>	<424098E2.6090007@pobox.com> <20050322141714.4515258f.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050322141714.4515258f.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Tue, 22 Mar 2005 17:14:58 -0500
> Jeff Garzik <jgarzik@pobox.com> wrote:
> 
> 
>>OK, so this is not a tg3-related problem at all.
> 
> 
> Right.
> 
> 
>>It really sounds like you should update pci_msi_quirk() to cover the 
>>other affected cases.
> 
> 
> That's not possible without either:
> 
> 1) getting a lot of chipset vendors to reveal stuff they probably
>    would rather keep secret (ie. that their chip in particular has
>    MSI problems)
> 
> 2) having a device on which to perform the MSI usability check
> 
> See #2?  That's the main issue from genericizing this, we need
> a device on which to perform the usability check so that we can
> handling a test interrupt and see if state got updated correctly.
> 
> So for the time being, Michael's change is OK until we find a
> better solution that really does cover all the problem chipsets.

I disagree: this will hide bugs.

We already have a standard process in Linux to handle this stuff:

* avoid platform tests in the driver
* when the driver fails, have the user try "pci=nomsi"
* if that works, add system to blacklist

In short, the tg3 driver -without- the MSI test is actually a better MSI 
test.

And as an added bonus, hardware setups with buggy MSI are easily 
highlighted.

MSI is going to hit big, real soon.  We don't need this sort of test in 
ever driver... that will just slow the deployment of a kernel that knows 
which systems are bad for MSI.

	Jeff, who just added MSI support to AHCI SATA driver
