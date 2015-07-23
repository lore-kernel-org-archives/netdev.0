From: Antonio Borneo <borneo.antonio@gmail.com>
Subject: Re: [PATCH] net: via/Kconfig: GENERIC_PCI_IOMAP required if PCI not selected
Date: Thu, 23 Jul 2015 09:35:51 +0800
Message-ID: <CAAj6DX3WpzogwYFa4EQ-b1o+n-4kE0iXOokYQA5NpV=3YBmM_A@mail.gmail.com>
References: <1437582854-3320-1-git-send-email-borneo.antonio@gmail.com>
	<20150722.110836.422018977846427052.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	netdev@vger.kernel.org, linux-next@vger.kernel.org,
	Alexey Charkov <alchark@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:33526 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752586AbbGWBfw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 21:35:52 -0400
In-Reply-To: <20150722.110836.422018977846427052.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 23, 2015 at 2:08 AM, David Miller <davem@davemloft.net> wrote:
> From: Antonio Borneo <borneo.antonio@gmail.com>
> Date: Thu, 23 Jul 2015 00:34:14 +0800
>
>> -     depends on (PCI || OF_IRQ)
>> +     depends on (PCI || (OF_IRQ && GENERIC_PCI_IOMAP))
>
> Having GENERIC_PCI_IOMAP withut PCI makes absolutely no sense to me.
>
> I can't see why a platform would provide GENERIC_PCI_IOMAP when it
> does not have PCI enabled.

My understanding for GENERIC_PCI_IOMAP is to enable providing empty
pci_iomap/pci_iounmap.
Digging in git log, arch that used to provide such empty instances
moved to a centralized implementation by using GENERIC_PCI_IOMAP.
For me such empty functions should be available by default when PCI is
not set, but this is not the case today.

So there are cases that set GENERIC_PCI_IOMAP without setting PCI. E.g.
make ARCH=mips workpad_defconfig
make ARCH=microblaze allnoconfig

Moreover, in lib/Kconfig GENERIC_PCI_IOMAP is selected when
GENERIC_IOMAP is set, without dependencies from PCI.

You can also check
https://lkml.org/lkml/2013/9/11/76
already upstream in commit
78857614104a26cdada4c53eea104752042bf5a1

Anyway, no other Kconfig uses GENERIC_PCI_IOMAP within conditionals,
which makes this patch quite unusual.

If you think this is not the way to go, we can consider to revert both
0f8b6cea1f3271ccc37dd2847b39e235461e0ced
b7d3282a245f44286b88e436b1d08c518cdf4569
and take some more time for a different solution.

Regards,
Antonio

> You need to explain this.
>
> When PCI is not enabled, you should not be using any interface
> pci_*() whatsoever.  Especially such a core interface as pci_iomap().
>
> ALTERNATIVELY, NOP versions of pci_iomap() and friends should be
> provided when PCI is disabled, which just return errors and
> non-success statuses.
