From: Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 17/21] orinoco_pci: use pci_iomap() for resources
Date: Sat, 08 Apr 2006 11:00:14 -0400
Message-ID: <4437CFFE.5000108@pobox.com>
References: <20060407081019.16107.67672.stgit@dv.roinet.com>	<20060407081053.16107.19347.stgit@dv.roinet.com>	<20060407213619.GB15720@electric-eye.fr.zoreil.com>	<1144448517.5618.14.camel@dv>	<20060407233819.GB15667@electric-eye.fr.zoreil.com> <20060407200731.mqskowo8808gccs8@webmail.spamcop.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
In-Reply-To: <20060407200731.mqskowo8808gccs8-2RFepEojUI3Rd1RZctBqVdHuzzzSOjJt@public.gmane.org>
Sender: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=orinoco-devel>
List-Id: netdev.vger.kernel.org

Pavel Roskin wrote:
> Quoting Francois Romieu <romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org>:
>>>> Is there a reason why dev->mem_{start/end} should not be removed ?
>>> Is there a reason why it should? Is it going to be obsolete?
>> It is slowly obsoleting for a few years (don't laugh...). It is preferred
>> to store the relevant address in the private part of the (pci) device.
>>
>> Moderately recent drivers do not use it at all. However it's fairly common
>> in the setup code of the (legacy) isa devices.
> 
> I agree that many drivers don't use it.  But it would be nice to have a document
> describing what is going on.  On one hand we are adding new information elements
> (such as the bus in "ethtool -i"), on the other hand we are removing addresses
> from the ifconfig output.  Who is deciding which information is useful and 
> which is not?

Most of the ifconfig-exported stuff is obsolete, simply because most of 
it is quite inappropriate for hardware more modern than ISA. 
dev->mem_start has been a hacky way to pass options for over 10 years 
now, since only few, rare drivers use it to specify the ISA memory 
region for probing.


> How about netdev->irq?  Is it going to be obsolete too?  Then I can easily
> remove orinoco_pci_setup_netdev() with very minimal adjustments.

netdev->irq is obsolete as well.  Some newer drivers don't even bother 
to set it.  With PCI, it became write-only, because modern drivers 
autoprobe their irq, ignoring whatever the user requests.  With PCI 
MSI[-X] and even more modern hardware, dev->irq is just a cookie, not 
something to program PCI_INTERRUPT_LINE with.  So setting netdev->irq is 
even less useful.

Programs which need to discover hardware information when given a 
network interface name should do ETHTOOL_GDRVINFO, get the bus info, and 
then obtain the information needed in a bus-specific way.

	Jeff




-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
