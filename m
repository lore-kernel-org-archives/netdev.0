From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: Mostly revert "e1000/e1000e: Move PCI-Express device IDs over
 to e1000e"
Date: Wed, 30 Jan 2008 08:23:29 -0800
Message-ID: <47A0A481.3000504@intel.com>
References: <200801292359.m0TNxb75011826@hera.kernel.org> <20080129212314.91b9bb5b.randy.dunlap@oracle.com> <alpine.LFD.1.00.0801301631400.3426@www.l.google.com> <47A04C07.1040200@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	akpm <akpm@linux-foundation.org>, NetDev <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:48838 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751544AbYA3QcG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2008 11:32:06 -0500
In-Reply-To: <47A04C07.1040200@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik wrote:
> Linus Torvalds wrote:
>>
>> On Tue, 29 Jan 2008, Randy Dunlap wrote:
>>> Andrew was concerned about this when the driver was in -mm.
>>> He asked for a patch that would set E1000E to same value as E1000
>>> and I supplied that.  Auke acked it IIRC.  Other people vetoed it.  :(
>>
>> Yeah, I've been discussing with Jeff and the gang.
>>
>> I think we have agreed on a solution where the ID's show up in the old
>> driver if the new driver is not enabled at all.
>>
>> (And as a side note: it turns out that the problem I experienced
>> didn't come from the new e1000e driver after all, so I'll be removing
>> the EXPERIMENTAL flag again).
>>
>> So I'd suggest the final patch be something like this, but I'm sendign
>> it out just as an example of how we could solve this, not necessarily
>> as a final patch.
>>
>> Jeff, Auke, would something like this be acceptable? It makes it very
>> obvious in the driver table which entries are for the PCIE versions
>> that would be handled by the E1000E driver if it is enabled..
>>
>> Untested, but as mentioned, this is more of a "this looks maintainable
>> and like it should solve the issues" rather than anything I was
>> planning on committing now.
>>
>>         Linus
>> ---
>>  drivers/net/Kconfig            |    5 ++-
>>  drivers/net/e1000/e1000_main.c |   60
>> ++++++++++++++++++++++------------------
>>  2 files changed, 37 insertions(+), 28 deletions(-)
>>
>> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
>> index 5a2d1dd..6c57540 100644
>> --- a/drivers/net/Kconfig
>> +++ b/drivers/net/Kconfig
>> @@ -1992,7 +1992,7 @@ config E1000_DISABLE_PACKET_SPLIT
>>  
>>  config E1000E
>>      tristate "Intel(R) PRO/1000 PCI-Express Gigabit Ethernet support"
>> -    depends on PCI && EXPERIMENTAL
>> +    depends on PCI
>>      ---help---
>>        This driver supports the PCI-Express Intel(R) PRO/1000 gigabit
>>        ethernet family of adapters. For PCI or PCI-X e1000 adapters,
>> @@ -2009,6 +2009,9 @@ config E1000E
>>        To compile this driver as a module, choose M here. The module
>>        will be called e1000e.
>>  
>> +config E1000E_ENABLED
>> +    def_bool E1000E != n
>> +
>>  config IP1000
>>      tristate "IP1000 Gigabit Ethernet support"
>>      depends on PCI && EXPERIMENTAL
>> diff --git a/drivers/net/e1000/e1000_main.c
>> b/drivers/net/e1000/e1000_main.c
>> index 3111af6..8c87940 100644
>> --- a/drivers/net/e1000/e1000_main.c
>> +++ b/drivers/net/e1000/e1000_main.c
>> @@ -47,6 +47,12 @@ static const char e1000_copyright[] = "Copyright
>> (c) 1999-2006 Intel Corporation
>>   * Macro expands to...
>>   *   {PCI_DEVICE(PCI_VENDOR_ID_INTEL, device_id)}
>>   */
>> +#ifdef CONFIG_E1000E_ENABLED
>> +  #define PCIE(x) +#else
>> +  #define PCIE(x) x,
>> +#endif
> 
> Patch gets my ACK, if you like, though an improvement would be to have
> your Kconfig logic activate CONFIG_E1000_PCIEX.  Then future janitors
> could come along and disable unused code in addition to PCI IDs.

Ack from my side as well, allthough I hope that this code will not live long as I
would love to start taking out pci-e code out of e1000. If we merge this patch
then I suggest that we don't do that until for at least a whole cycle, since it
does not make much sense otherwise.

Auke
