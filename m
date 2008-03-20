From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [patch 16/17] drivers/net/8390.c: replace init_module&cleanup_module
 with module_init&module_exit
Date: Thu, 20 Mar 2008 11:15:19 -0700
Message-ID: <47E2A9B7.5010504@intel.com>
References: <200803042319.m24NJXjS002733@imap1.linux-foundation.org>	<47D1D70A.2070003@intel.com> <20080310115842.8b2ca9fd.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	jkschind@gmail.com, alan@lxorguk.ukuu.org.uk
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:37034 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757216AbYCTSPl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Mar 2008 14:15:41 -0400
In-Reply-To: <20080310115842.8b2ca9fd.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> On Fri, 07 Mar 2008 16:00:10 -0800
> "Kok, Auke" <auke-jan.h.kok@intel.com> wrote:
> 
>> akpm@linux-foundation.org wrote:
>>> From: Jon Schindler <jkschind@gmail.com>
>>>
>>> Replace init_module and cleanup_module with static functions and
>>> module_init/module_exit.
>>>
>>> Signed-off-by: Jon Schindler <jkschind@gmail.com>
>>> Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>
>>> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>> something went wrong here as this patch already appears to be in jeff's upstream
>> tree as commit 8724c2de65fe527f5b7aa662fcb8573fb8cd02f2, but breaks compile.
>>
>> with CONFIG_NE2K_PCI=m:
>>
>>   CC [M]  drivers/net/8390.o
>> drivers/net/8390.c: In function '__inittest':
>> drivers/net/8390.c:60: error: 'ns8390_init_module' undeclared (first use in this
>> function)
>> drivers/net/8390.c:60: error: (Each undeclared identifier is reported only once
>> drivers/net/8390.c:60: error: for each function it appears in.)
>> make[2]: *** [drivers/net/8390.o] Error 1
>> make[1]: *** [drivers/net] Error 2
>> make: *** [drivers] Error 2
>>
>>
>> reverting the patch fixes the issue, but better would be to fix.
>>
>> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
>> Cc: Jon Schindler <jkschind@gmail.com>
>> Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>>
>> ---
>> diff --git a/drivers/net/8390.c b/drivers/net/8390.c
>> index 0ed41a3..a499e86 100644
>> --- a/drivers/net/8390.c
>> +++ b/drivers/net/8390.c
>> @@ -57,7 +57,7 @@ static void __exit ns8390_module_exit(void)
>>  {
>>  }
>>
>> -module_init(ns8390_init_module);
>> +module_init(ns8390_module_init);
>>  module_exit(ns8390_module_exit);
>>  #endif /* MODULE */
>>  MODULE_LICENSE("GPL");
> 
> OK, thanks, I'll drop it.


Jeff,

this bug is now sitting in your upstream tree breaking my compiles :(

Please either apply my patch above or do what Andrew did.

thanks,

Auke


