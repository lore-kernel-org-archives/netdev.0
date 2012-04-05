From: Michael Schmitz <schmitzmic@googlemail.com>
Subject: Re: [PATCH] m68k/atari: EtherNEC - rewrite to use mainstream ne.c,
 take two
Date: Fri, 06 Apr 2012 10:10:19 +1200
Message-ID: <4F7E184B.6000903@gmail.com>
References: <1327085843-6980-1-git-send-email-geert@linux-m68k.org>	<4F4B2BB6.900@gmail.com>	<CAP=VYLqxtE4OamrdN2RXaQu_2kK5_57-x80z48JXzt+xEtQ7pw@mail.gmail.com>	<CAMuHMdX=4Vn=OsNTp04YcrhDOwz8NOFrWKankj2+3utvEfE-2A@mail.gmail.com>	<4F5A0679.1020604@windriver.com>	<4F7816B0.3090802@gmail.com>	<4F7CB31D.8060002@windriver.com> <CAMuHMdWSzG4npwjpJ=cwNFKhyBZjvgPn1sp6nZ2re6QsRWPpXg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	linux-m68k@vger.kernel.org, netdev@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdWSzG4npwjpJ=cwNFKhyBZjvgPn1sp6nZ2re6QsRWPpXg@mail.gmail.com>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Geert,
>> How much lower?  Enough to matter?  Implicit in that question is
>> the assumption that this is largely a hobbyist platform and nobody
>> is using it in a closet to route gigabytes of traffic.
>>     
>
> One other thing we could do is increase CONFIG_HZ to 250.
>   
Making 3.x kernels run even more sluggish than they already do?
>> Also, the only advantage to modifying ne.c is to allow dumping
>> the old driver.  What is the "remove soon" plan?  Any reason
>> for it to not be synchronous?  That would eliminate the Kconfig
>> churn and the introduction of the _OLD option.  Modifying ne.c
>> and then deciding to keep the old driver because it is "faster"
>> would make this change pointless.
>>     
>
> From my point of view, "remove soon" means it will never hit mainline.
>   
That's what I meant to say - my patch is based on the m68k tree which 
currently has another driver for this hardware, based on an older 
version of ne.c which was never submitted to mainline. The old driver 
would be removed from the m68k tree as soon as possible.
>> This seems more klunky than it needs to be.  If we assume that anyone
>> building ne.c on atari is hence trying to drive an ethernec device
>> than it can just be
>>
>> #ifdef CONFIG_ATARI
>> #define EI_IRQ_FLAGS    IRQF_SHARED
>> #else
>> #define EI_IRQ_FLAGS    0
>> #endif
>>     
>
> Indeed, with a small modification (keep multi-platform kernels in mind):
>
> #ifdef CONFIG_ATARI
> #define EI_IRQ_FLAGS    (MACH_IS_ATARI ? IRQF_SHARED : 0)
> #else
> #define EI_IRQ_FLAGS    0
> #endif
>   
Right you are. Is any other m68k platform using ne.c directly, or do you 
plan to convert all other NE2000 based drivers to ne.c now?

Cheers,

  Michael
