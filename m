From: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Subject: Re: [BUILD FAILURE]2.6.24-git6 build failure on sis190 ethernet driver
Date: Wed, 30 Jan 2008 13:31:50 +0530
Message-ID: <47A02EEE.9030508@linux.vnet.ibm.com>
References: <479FF1F0.10907@linux.vnet.ibm.com> <47A00057.9090306@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	romieu@fr.zoreil.com, Andy Whitcroft <apw@shadowen.org>
To: Gabriel C <nix.or.die@googlemail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755386AbYA3IHT@vger.kernel.org>
In-Reply-To: <47A00057.9090306@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gabriel C wrote:
> Kamalesh Babulal wrote:
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
>>
> 
> Heh :) vger.kernel.org does not like emails directly from gmail , it seems =)
> 
> ( sorry for sending this 3 time now )
> 
> The following patch should fix the build failure.
> 
> diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
> index b570402..e48e4ad 100644
> --- a/drivers/net/sis190.c
> +++ b/drivers/net/sis190.c
> @@ -326,7 +326,7 @@ static const struct {
>  	{ "SiS 191 PCI Gigabit Ethernet adapter" },
>  };
> 
> -static struct pci_device_id sis190_pci_tbl[] __devinitdata = {
> +static const struct pci_device_id sis190_pci_tbl[] __devinitdata = {
>  	{ PCI_DEVICE(PCI_VENDOR_ID_SI, 0x0190), 0, 0, 0 },
>  	{ PCI_DEVICE(PCI_VENDOR_ID_SI, 0x0191), 0, 0, 1 },
>  	{ 0, },
> 
> 
> Gabriel

Hi Gabriel,

Thanks, the patch fixes the build failure.


-- 
Thanks & Regards,
Kamalesh Babulal,
Linux Technology Center,
IBM, ISTL.
