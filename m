From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Subject: Re: 2.6.20-rc4-mm1: PCI=n: drivers/net/3c59x.c compile error
Date: Mon, 26 Feb 2007 16:22:27 +0300
Message-ID: <45E2DF13.9010200@ru.mvista.com>
References: <20070111222627.66bb75ab.akpm@osdl.org> <20070124135354.GI17836@stusta.de> <45B76946.1070009@ru.mvista.com> <45D756D7.4060106@ru.mvista.com> <45D75853.1060607@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@stusta.de>, Andrew Morton <akpm@osdl.org>,
	Jeff Garzik <jgarzik@pobox.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: linux-pci@atrey.karlin.mff.cuni.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from h155.mvista.com ([63.81.120.155]:57401 "EHLO imap.sh.mvista.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1030221AbXBZNWk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Feb 2007 08:22:40 -0500
In-Reply-To: <45D75853.1060607@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, I wrote:

>>>> 3x59x-fix-pci-resource-management.patch causes the following compile 
>>>> error with CONFIG_PCI=n:

>>>> <--  snip  -->

>>>> ...
>>>>   CC      drivers/net/3c59x.o
>>>> /home/bunk/linux/kernel-2.6/linux-2.6.20-rc4-mm1/drivers/net/3c59x.c: 
>>>> In function 'vortex_init_one':
>>>> /home/bunk/linux/kernel-2.6/linux-2.6.20-rc4-mm1/drivers/net/3c59x.c:961: 
>>>> error: implicit declaration of function 'pci_request_regions'
>>>> /home/bunk/linux/kernel-2.6/linux-2.6.20-rc4-mm1/drivers/net/3c59x.c:985: 
>>>> error: implicit declaration of function 'pci_release_regions'
>>>> make[3]: *** [drivers/net/3c59x.o] Error 1

>>>    Grr, at at the same time it's happy with pci_enable_device().
>>>    I'd say the problem is in <linux/pci.h>,  not in the patch.

>>    Has there been any patch to fix the "unbalanced" 
>> pci_{request|release}_regions() declarations? Am I suposed to create 
>> such?

>    Alternatively, vortex_{init|remove_one() and struct pci_driver there 
> could have been put under #ifdef CONFIG_PCI (good idea anyway -- should 
> reduce driver size on non-PCI systems)...

    I wonder if I may count on any feedback on this -- asking linux-pci now...
    The issue is as follows: with my patch pci_{request|release}_regions() may 
be called with CONFIG_PCI=n (probably, this never has been a issue before) but 
<linux/pci.h> don't have them declared in this case -- unlike 
pci_enable_device() which is just empty for CONFIG_PCI=n.
    Now, what kind of approach do I take:

- a "fair one", so that pci_{request|release}_regions() get "balanced"
   declarations in the header like pci_enable_device();

- a "local one" (and even saving non-PCI kernel from needless bloat), i.e.
   #ifdef out functions that are only meaningful with CONFIG_PCI=y)?

    I'm leaning to the second now...

>>>> cu
>>>> Adrian

MBR, Sergei
