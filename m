From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH] gianfar_ptp: use iomem, not ioports resource tree in
 probe
Date: Wed, 24 Oct 2012 15:09:55 -0400
Message-ID: <50883D03.1000600@windriver.com>
References: <1351092096-14811-1-git-send-email-paul.gortmaker@windriver.com> <6AE080B68D46FC4BA2D2769E68D765B70810B134@039-SN2MPN1-023.039d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wei Yang <Wei.Yang@windriver.com>,
	Manoil Claudiu-B08782 <B08782@freescale.com>
To: Tabi Timur-B04825 <B04825@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:48596 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965086Ab2JXTJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2012 15:09:59 -0400
In-Reply-To: <6AE080B68D46FC4BA2D2769E68D765B70810B134@039-SN2MPN1-023.039d.mgd.msft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12-10-24 01:59 PM, Tabi Timur-B04825 wrote:
> On Wed, Oct 24, 2012 at 10:21 AM, Paul Gortmaker
> <paul.gortmaker@windriver.com> wrote:
>> From: Wei Yang <Wei.Yang@windriver.com>
>>
>> When using a 36 bit dtb file, the driver complains "resource busy".
>>
>> Investigating the source of the message leads one to the
>> gianfar_ptp_probe function.
>>
>> Since the type of the device resource requested in this function
>> is IORESOURCE_MEM, it should use "iomem_resource" instead of
>> "ioports_resource".
> 
> I can't comment on this patch, since I didn't write the driver, but I
> am confused on one thing.  Why is the driver using platform_xxx calls

Even if it makes sense to convert the driver to of_xxx calls,
I think the obvious bug should be fixed as a separate commit,
so that the -stable folks have something to cherry pick.

P.
--

> to get data?  Why isn't it using of_xxx calls to read properties from
> the device tree?  For example, why is it using
> 
> 	etsects->irq = platform_get_irq(dev, 0);
> 
> to get the IRQ?  Shouldn't it do this instead:
> 
> 	etsects->irq = irq_of_parse_and_map(node, 0);
> 
