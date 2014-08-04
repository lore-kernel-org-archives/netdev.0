From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] drivers/isdn/hisax/Kconfig: Let HISAX_NETJET skip
 microblaze architecture
Date: Mon, 4 Aug 2014 21:44:04 +0200
Message-ID: <CAMuHMdVGgW11UziFieCgXT7mSNA=_QgOaGAt42kEXqU9CUgqxA@mail.gmail.com>
References: <53DFCFC9.6060307@gmail.com>
	<20140804212354.74b97cd7@endymion.delvare>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Chen Gang <gang.chen.5i5j@gmail.com>,
	Karsten Keil <isdn@linux-pingi.de>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Michal Simek <monstr@monstr.eu>
To: Jean Delvare <jdelvare@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140804212354.74b97cd7@endymion.delvare>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 4, 2014 at 9:23 PM, Jean Delvare <jdelvare@suse.de> wrote:
>> --- a/drivers/isdn/hisax/Kconfig
>> +++ b/drivers/isdn/hisax/Kconfig
>> @@ -237,7 +237,7 @@ config HISAX_MIC
>>
>>  config HISAX_NETJET
>>       bool "NETjet card"
>> -     depends on PCI && (BROKEN || !(PPC || PARISC || M68K || (MIPS && !CPU_LITTLE_ENDIAN) || FRV || (XTENSA && !CPU_LITTLE_ENDIAN)))
>> +     depends on PCI && (BROKEN || !(PPC || PARISC || M68K || (MIPS && !CPU_LITTLE_ENDIAN) || FRV || (XTENSA && !CPU_LITTLE_ENDIAN) || MICROBLAZE))
>>       depends on VIRT_TO_BUS
>>       help
>>         This enables HiSax support for the NetJet from Traverse
>> @@ -249,7 +249,7 @@ config HISAX_NETJET
>>
>>  config HISAX_NETJET_U
>>       bool "NETspider U card"
>> -     depends on PCI && (BROKEN || !(PPC || PARISC || M68K || (MIPS && !CPU_LITTLE_ENDIAN) || FRV || (XTENSA && !CPU_LITTLE_ENDIAN)))
>> +     depends on PCI && (BROKEN || !(PPC || PARISC || M68K || (MIPS && !CPU_LITTLE_ENDIAN) || FRV || (XTENSA && !CPU_LITTLE_ENDIAN) || MICROBLAZE))
>>       depends on VIRT_TO_BUS
>>       help
>>         This enables HiSax support for the Netspider U interface ISDN card
>
> Fine with me, however the list is getting long. It would be better if
> we could depend on a functional symbol rather than a negated list of
> architectures. Would it make sense to have CONFIG_CPU_LITTLE_ENDIAN
> defined on all little-endian architectures, so that driver can depend
> on that if needed?

Yes, that idea pops up once in a while.

BTW, these days little endian PPC is also supported by Linux...

> Alternatively, it might make more sense to list the architectures where
> these drivers are actually used in practice. I guess that's X86, maybe
> ARM and IA64, and that's all?

|| COMPILE_TEST ....

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
