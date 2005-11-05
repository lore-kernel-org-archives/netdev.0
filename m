From: Richard Knutsson <ricknu-0@student.ltu.se>
Subject: Re: [PATCH]dgrs - Fixes Warnings when CONFIG_ISA and CONFIG_PCI are
 not enabled
Date: Sat, 05 Nov 2005 12:54:27 +0100
Message-ID: <436C9D73.5030506@student.ltu.se>
References: <81083a450511012314q4ec69927gfa60cb19ba8f437a@mail.gmail.com>	<4368878D.4040406@student.ltu.se>	<c216304e0511020516o5cfcd0b9u96a3220bf2694928@mail.gmail.com>	<436927CA.3090105@student.ltu.se>	<20051104182537.741be3d9.akpm@osdl.org>	<20051104183043.27a2229c.akpm@osdl.org>	<436C6F02.90904@student.ltu.se> <20051105004609.0f04481c.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ashutosh.lkml@gmail.com, netdev@vger.kernel.org, davej@suse.de,
	acme@conectiva.com.br, linux-net@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751480AbVKELt6@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20051105004609.0f04481c.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:

>Richard Knutsson <ricknu-0@student.ltu.se> wrote:
>  
>
>>>	 */
>>>      
>>>
>> > #ifdef CONFIG_EISA
>> >-	eisacount = eisa_driver_register(&dgrs_eisa_driver);
>> >-	if (eisacount < 0)
>> >-		return eisacount;
>> >-#endif
>> >-#ifdef CONFIG_PCI
>> >-	pcicount = pci_register_driver(&dgrs_pci_driver);
>> >-	if (pcicount)
>> >-		return pcicount;
>> >+	cardcount = eisa_driver_register(&dgrs_eisa_driver);
>> >+	if (cardcount < 0)
>> >+		return cardcount;
>> > #endif
>> >+	cardcount = pci_register_driver(&dgrs_pci_driver);
>> >+	if (cardcount)
>> >+		return cardcount;
>> > 	return 0;
>> > }
>> >  
>> >
>> I do not know what to think about this one:
>> * reduce one #ifdef: good
>> * check for something clearly stated not to: not so good
>>    
>>
>
>Well a nicer fix would be to provide a stub implementation of
>eisa_driver_register() if !CONFIG_EISA, just like pci_register_driver(). 
>Then all the ifdefs go away and the compiler removes all the code for us,
>after checking that we typed it correctly.
>  
>
Oh, sorry. Missed the stub implementation of the pci-driver. I "ack" 
your patch.

BTW, can anyone ack or is that up to the maintainers?
BTW #2, why not remove #ifdef CONFIG_PCI on dgrs_cleanup_module() at the 
same time? Or maybe that should be in a "remove config_pci"-patch...

/Richard
