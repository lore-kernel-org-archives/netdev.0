From: Alexey Charkov <alchark@gmail.com>
Subject: Re: [PATCH] net: via/Kconfig: GENERIC_PCI_IOMAP required if PCI not selected
Date: Thu, 23 Jul 2015 18:33:36 +0300
Message-ID: <CABjd4Yx5YTEqUVGF+OqddB-q6u4u7boQK1ndcCKteQCa1LxubA@mail.gmail.com>
References: <1437582854-3320-1-git-send-email-borneo.antonio@gmail.com>
	<20150722.110836.422018977846427052.davem@davemloft.net>
	<CAAj6DX3WpzogwYFa4EQ-b1o+n-4kE0iXOokYQA5NpV=3YBmM_A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	netdev <netdev@vger.kernel.org>, linux-next@vger.kernel.org
To: Antonio Borneo <borneo.antonio@gmail.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <CAAj6DX3WpzogwYFa4EQ-b1o+n-4kE0iXOokYQA5NpV=3YBmM_A@mail.gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2015-07-23 4:35 GMT+03:00 Antonio Borneo <borneo.antonio@gmail.com>:
> On Thu, Jul 23, 2015 at 2:08 AM, David Miller <davem@davemloft.net> wrote:
>> From: Antonio Borneo <borneo.antonio@gmail.com>
>> Date: Thu, 23 Jul 2015 00:34:14 +0800
>>
>>> -     depends on (PCI || OF_IRQ)
>>> +     depends on (PCI || (OF_IRQ && GENERIC_PCI_IOMAP))
>>
>> Having GENERIC_PCI_IOMAP withut PCI makes absolutely no sense to me.
>>
>> I can't see why a platform would provide GENERIC_PCI_IOMAP when it
>> does not have PCI enabled.
>
> My understanding for GENERIC_PCI_IOMAP is to enable providing empty
> pci_iomap/pci_iounmap.

There is also a non-empty implementation that calls to ioremap/iounmap
(compiled in when PCI=y). So it's rather an option that every
architecture should use if they don't have any special requirements
(which seems to be true about SH, too). Maybe a name like
"MY_ARCH_DOESNT_NEED_ANYTHING_SPECIAL_FROM_PCI_IOMAP" instead of
GENERIC_PCI_IOMAP would be more reflective of its current semantics,
but it doesn't look very pretty anyway :)

> Digging in git log, arch that used to provide such empty instances
> moved to a centralized implementation by using GENERIC_PCI_IOMAP.
> For me such empty functions should be available by default when PCI is
> not set, but this is not the case today.

If we trust the commit message in
97a29d59fc222b36bac3ee3a8ae994f65bf7ffdf
it looks like architectures that use their own PCI mapping functions
would provide them unconditionally, so we shouldn't unconditionally
include stubs in the generic header to avoid double definition.

I think the way to fix this most consistently with what other arches
do would be to move "select GENERIC_PCI_IOMAP" from arch/sh/Kconfig
outside of "config PCI" (towards line 40 or so in the same file). This
will ensure that all NOP stubs are applied correctly to avoid such
compile-time errors.

Happy to provide a 2-line patch to do the above, but I don't have any
SH hardware to test.

Best,
Alexey
