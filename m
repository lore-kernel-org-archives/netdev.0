From: Pierre Peiffer <pierre.peiffer@bull.net>
Subject: Re: [PATCH 2.6.24-mm1] error compiling net driver NE2000/NE1000
Date: Mon, 18 Feb 2008 16:04:24 +0100
Message-ID: <47B99E78.4070807@bull.net>
References: <20080204162921.94984e72.pierre.peiffer@bull.net> <20080204131038.699c28c1.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:38913 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752391AbYBRPET (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2008 10:04:19 -0500
In-Reply-To: <20080204131038.699c28c1.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

	I don't know if I have to warn on this or not, but as I didn't find any
discussion, it's probably better to mention it: the compiling error reported
below (or here: http://lkml.org/lkml/2008/2/4/173 ) does not seem to be
corrected in 2.6.25-rc2.mm1...  So, I don't know if a fix is going on somewhere
or if the bug has fallen in a black hole.

(In the original mail, I've proposed a patch as a quick fix, but I don't know if
it can be considered as a definitive correction or not)

Thanks,

P.

Andrew Morton wrote:
> On Mon, 4 Feb 2008 16:29:21 +0100
> Pierre Peiffer <pierre.peiffer@bull.net> wrote:
> 
>> Hi,
>>
>> 	When I compile the kernel 2.6.24-mm1 with:
>> CONFIG_NET_ISA=y
>> CONFIG_NE2000=y
>>
>> I have the following compile error:
>> ...
>>   GEN     .version
>>   CHK     include/linux/compile.h
>>   UPD     include/linux/compile.h
>>   CC      init/version.o
>>   LD      init/built-in.o
>>   LD      .tmp_vmlinux1
>> drivers/built-in.o: In function `ne_block_output':
>> linux-2.6.24-mm1/drivers/net/ne.c:797: undefined reference to `NS8390_init'
>> drivers/built-in.o: In function `ne_drv_resume':
>> linux-2.6.24-mm1/drivers/net/ne.c:858: undefined reference to `NS8390_init'
>> drivers/built-in.o: In function `ne_probe1':
>> linux-2.6.24-mm1/drivers/net/ne.c:539: undefined reference to `NS8390_init'
>> make[1]: *** [.tmp_vmlinux1] Error 1
>> make: *** [sub-make] Error 2
> 
> Thanks for reporting this.
> 
>> As I saw that the file 8390p.c is compiled for this driver, but not the file 
>> 8390.c which contains this function NS8390_init(), I fixed this error with
>> the following patch.
> 
> Alan's
> 8390-split-8390-support-into-a-pausing-and-a-non-pausing-driver-core.patch
> would be a prime suspect.  I assume this bug isn't present ing mainline or
> in 2.6.24?
> 
>> As NS8390p_init() does the same thing than NS8390_init(), I suppose that this is the right fix ?
>>
>> Signed-off-by: Pierre Peiffer <pierre.peiffer@bull.net>
>> ---
>>  drivers/net/ne.c |    6 +++---
>>  1 file changed, 3 insertions(+), 3 deletions(-)
>>
>> Index: b/drivers/net/ne.c
>> ===================================================================
>> --- a/drivers/net/ne.c
>> +++ b/drivers/net/ne.c
>> @@ -536,7 +536,7 @@ static int __init ne_probe1(struct net_d
>>  #ifdef CONFIG_NET_POLL_CONTROLLER
>>  	dev->poll_controller = eip_poll;
>>  #endif
>> -	NS8390_init(dev, 0);
>> +	NS8390p_init(dev, 0);
>>  
>>  	ret = register_netdev(dev);
>>  	if (ret)
>> @@ -794,7 +794,7 @@ retry:
>>  		if (time_after(jiffies, dma_start + 2*HZ/100)) {		/* 20ms */
>>  			printk(KERN_WARNING "%s: timeout waiting for Tx RDC.\n", dev->name);
>>  			ne_reset_8390(dev);
>> -			NS8390_init(dev,1);
>> +			NS8390p_init(dev,1);
>>  			break;
>>  		}
>>  
>> @@ -855,7 +855,7 @@ static int ne_drv_resume(struct platform
>>  
>>  	if (netif_running(dev)) {
>>  		ne_reset_8390(dev);
>> -		NS8390_init(dev, 1);
>> +		NS8390p_init(dev, 1);
>>  		netif_device_attach(dev);
>>  	}
>>  	return 0;
> 
> 
> 
> 

-- 
Pierre Peiffer
