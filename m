From: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Subject: Re: [BUILD FAILURE]2.6.24-git6 build failure on sis190 ethernet driver
Date: Wed, 30 Jan 2008 13:33:43 +0530
Message-ID: <47A02F5F.4010205@linux.vnet.ibm.com>
References: <479FF1F0.10907@linux.vnet.ibm.com> <20080130053451.GA18641@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	romieu@fr.zoreil.com, Andy Whitcroft <apw@shadowen.org>
To: Sam Ravnborg <sam@ravnborg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp03.in.ibm.com ([59.145.155.3]:52800 "EHLO
	e28esmtp03.in.ibm.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751730AbYA3IIw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 03:08:52 -0500
In-Reply-To: <20080130053451.GA18641@uranus.ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sam Ravnborg wrote:
> On Wed, Jan 30, 2008 at 09:11:36AM +0530, Kamalesh Babulal wrote:
>> Hi,
>>
>> The 2.6.24-git6 kernel build fails on various x86_64 machines with the build failure
>>
>> drivers/net/sis190.c:329: error: sis190_pci_tbl causes a section type conflict
>> make[2]: *** [drivers/net/sis190.o] Error 1
>>
>> # gcc --version (machine1)
>> gcc (GCC) 4.1.1 20070105 (Red Hat 4.1.1-52)
>>
>> # gcc --version (machine2)
>> gcc (GCC) 4.1.1 20060525 (Red Hat 4.1.1-1)
> 
> Hi Kamalesh
> 
> I know another patch is circulating, but please try the following.

Hi Sam,

Thanks, the patch fixes the build failure.

Tested-by: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>

> diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
> index b570402..0a5e024 100644
> --- a/drivers/net/sis190.c
> +++ b/drivers/net/sis190.c
> @@ -1556,7 +1556,7 @@ static int __devinit sis190_get_mac_addr_from_eeprom(struct pci_dev *pdev,
>  static int __devinit sis190_get_mac_addr_from_apc(struct pci_dev *pdev,
>  						   struct net_device *dev)
>  {
> -	static const u16 __devinitdata ids[] = { 0x0965, 0x0966, 0x0968 };
> +	static const u16 __devinitconst ids[] = { 0x0965, 0x0966, 0x0968 };
>  	struct sis190_private *tp = netdev_priv(dev);
>  	struct pci_dev *isa_bridge;
>  	u8 reg, tmp8;
> 
> It is the better fix if you can confirm it working.
> The section conflict issued by gcc happens because we try to
> mix const and non-const data in the same section.
> 
> 	Sam


-- 
Thanks & Regards,
Kamalesh Babulal,
Linux Technology Center,
IBM, ISTL.
