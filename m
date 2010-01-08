From: "H Hartley Sweeten" <hartleys@visionengravers.com>
Subject: RE: [PATCH] drivers/net/defxx.c: use %pMF to show MAC address
Date: Thu, 7 Jan 2010 21:11:34 -0500
Message-ID: <BD79186B4FD85F4B8E60E381CAEE19090208961F@mi8nycmail19.Mi8.com>
References: <201001071624.20139.hartleys@visionengravers.com> <1262914750.10429.88.camel@Joe-Laptop.home> <alpine.LFD.2.00.1001080143250.13474@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Linux Kernel" <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <davem@davemloft.net>
To: "Maciej W. Rozycki" <macro@linux-mips.org>,
	"Joe Perches" <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod6og107.obsmtp.com ([64.18.1.208]:34765 "HELO
	exprod6og107.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750983Ab0AHCLh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 21:11:37 -0500
Content-class: urn:content-classes:message
In-Reply-To: <alpine.LFD.2.00.1001080143250.13474@eddie.linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, January 07, 2010 7:06 PM, Maciej W. Rozycki wrote:
> On Thu, 7 Jan 2010, Joe Perches wrote:
>
>> On Thu, 2010-01-07 at 16:24 -0700, H Hartley Sweeten wrote:
>>> Use the %pMF kernel extension to display the MAC address.
>>> The address will still be displayed in the FDDI Canonical format.
>> 
>>> diff --git a/drivers/net/defxx.c b/drivers/net/defxx.c
>>> index 6a6ea03..e4eac4b 100644
>>> --- a/drivers/net/defxx.c
>>> +++ b/drivers/net/defxx.c
>>> @@ -1052,12 +1052,9 @@ static int __devinit dfx_driver_init(struct net_device *dev,
>>>  		board_name = "DEFEA";
>>>  	if (dfx_bus_pci)
>>>  		board_name = "DEFPA";
>>> -	pr_info("%s: %s at %saddr = 0x%llx, IRQ = %d, "
>>> -		"Hardware addr = %02X-%02X-%02X-%02X-%02X-%02X\n",
>>> +	pr_info("%s: %s at %saddr = 0x%llx, IRQ = %d, Hardware addr = %pMF\n",
>>>  		print_name, board_name, dfx_use_mmio ? "" : "I/O ",
>> 
>> I believe the output will _now_ be in the canonical form.
>> Before it wasn't bit reversed.  Now it should be.
>
> Output was correct -- why would you assume otherwise?  The bit order in 
> the MLA (My Long Address) register as retrieved from the MAC chip by 
> board's firmware has nothing to do with the wire order and is already in 
> the canonical form (the same applies to CAM entries and frame headers) -- 
> the board designers were sane people.
>
> With the two patches in place the output produced is now broken. :(
>

Ugh.. This is a mess...

David,

Can you please un-apply both this patch and the one for skfddi.c?
I think they should both use some form of the %p[mMF] format to display
the address but it appears Maciej is the only person that really knows
what the output _should" be...

Oh well... So much for trying to make things consistent...

Regards,
Hartley
