From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] Re: Bad network performance over 2Gbps
Date: Mon, 21 Apr 2008 09:38:49 -0700
Message-ID: <480CC319.5020500@intel.com>
References: <1208282804.23631.27.camel@localhost> <175f5a0f0804151315x1e192fc7p7dac1e84fd154211@mail.gmail.com> <48051173.5030802@intel.com> <48051734.1000107@redhat.com> <1208426550.6049.10.camel@localhost> <48078AF6.2020003@intel.com> <20080421131937.GA4685@ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Anton Titov <a.titov@host.bg>, Chris Snook <csnook@redhat.com>,
	"H. Willstrand" <h.willstrand@gmail.com>, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Pavel Machek <pavel@ucw.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:10870 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753369AbYDUQkG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Apr 2008 12:40:06 -0400
In-Reply-To: <20080421131937.GA4685@ucw.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Machek wrote:
> Hi!
> 
>> [X86] IRQBALANCE: Mark as BROKEN and disable by default
>>
>> The IRQBALANCE option causes interrupts to bounce all around on SMP systems
>> quickly burying the CPU in migration cost and cache misses. Mainly affected are
>> network interrupts and this results in one CPU pegged in softirqd completely.
>>
>> Disable this option and provide documentation to a better solution (userspace
>> irqbalance daemon does overall the best job to begin with and only manual setting
>> of smp_affinity will beat it).
>>
>> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
>>
>> ---
>>
>> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
>> index 6c70fed..956aa22 100644
>> --- a/arch/x86/Kconfig
>> +++ b/arch/x86/Kconfig
>> @@ -1026,13 +1026,17 @@ config EFI
>>    	platforms.
>>
>>  config IRQBALANCE
>> -	def_bool y
>> +	def_bool n
> 
> ACK.
>>  	prompt "Enable kernel irq balancing"
>> -	depends on X86_32 && SMP && X86_IO_APIC
>> +	depends on X86_32 && SMP && X86_IO_APIC && BROKEN
> 
> This is wrong. irqbalance works, there's nothing wrong with it; but it
> has nasty sideffects.

ok, I'm fine with taking that part out of the patch.

Ingo, want me to send an updated patch?


> 
>>  	help
>>  	  The default yes will allow the kernel to do irq load balancing.
>>  	  Saying no will keep the kernel from doing irq load balancing.
>>
>> +	  This option is known to cause performance issues on SMP
>> +	  systems. The preferred method is to use the userspace
>> +	  'irqbalance' daemon instead. See http://irqbalance.org/.
>> +
> 
> ACK.
> 

