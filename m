From: Pavel Fedin <p.fedin@samsung.com>
Subject: RE: [PATCH 3/6] net: thunderx: Increase transmit queue length
Date: Wed, 02 Dec 2015 16:22:13 +0300
Message-ID: <013401d12d04$75928230$60b78690$@samsung.com>
References: <y@samsung.com>
 <1448961223-41888-4-git-send-email-sunil.kovvuri@gmail.com>
 <01d101d12c46$2de43b40$89acb1c0$@samsung.com>
 <1448983985.25582.35.camel@edumazet-glaptop2.roam.corp.google.com>
 <CA+sq2Ce9oH-kCDO8hK_wX+ZZdXyyBuT4V2bt5Ab+2=pEX+BO+w@mail.gmail.com>
 <00cb01d12ce0$9f090540$dd1b0fc0$@samsung.com>
 <00eb01d12cec$a32aa500$e97fef00$@samsung.com>
 <013301d12cfd$0c958a90$25c09fb0$@samsung.com>
 <CA+sq2CfSNBQaQnw32tu4ZcZYLd6ybVZ3Ka5Oz=s1YUNegZpd-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: 'Eric Dumazet' <eric.dumazet@gmail.com>,
	'Linux Netdev List' <netdev@vger.kernel.org>,
	'LKML' <linux-kernel@vger.kernel.org>,
	'LAKML' <linux-arm-kernel@lists.infradead.org>,
	'Sunil Goutham' <Sunil.Goutham@caviumnetworks.com>,
	'Sunil Goutham' <sgoutham@cavium.com>
To: 'Sunil Kovvuri' <sunil.kovvuri@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.w1.samsung.com ([210.118.77.13]:32350 "EHLO
	mailout3.w1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756555AbbLBNWR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 08:22:17 -0500
In-reply-to: <CA+sq2CfSNBQaQnw32tu4ZcZYLd6ybVZ3Ka5Oz=s1YUNegZpd-A@mail.gmail.com>
Content-language: ru
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Hello!

> >After getting it working in guest i tried to apply it to host. With total of 128 virtual
> functions (= 128 interfaces) it does not work at all.
> > Even after bumping cma region size to insane value of 2GB more than half of interfaces still
> failed to allocate queues.
> > And after setting cma=3G i could not mount my rootfs.
> 
> Here what you are saying is half of the interfaces were initialized
> succesfully and rest didn't.

 After setting cma=2G. With default setting of 16M none of them initialized.

> So this issue is not something which is introduced by this patch.

 Before this patch all my interfaces were working.
 I would say the problem with your patch is that it introduces memory requirements which cannot be satisfied by the platform. It's combination of several factors which stops the thing from working, not a single factor. Using dma_alloc_coherent() is not all wrong by itself, of course.
 Perhaps you did some tricks with your configuration, which make it working. Then, i guess, you should have at least described them in commit message of your patch. Or describe all dependencies in KConfig of your driver, which is better. Or, if the platform needs some very special defconfig, add it to arch/arm64/configs (however, i guess, the goal of ARM64 Linux is to run on all possible hardware, so this would not be good from maintainers' POV).

 Sorry, but this is all i can say. In previous messages i have already suggested several ways to solve the problem (too lazy to quite here, 4 IIRC), or you can suggest your own one and let us test it, or you can even stick to "It works for me, i am the only right guy in the world, and i don't care if it doesn't work for you" position and let David decide who of us is right (and he already did that once).
 Basically, here is what i did: i took kernel 4.2, added ThunderX PCI drivers to it (they were posted but NAKed those days back, there's some lazy progress on them currently), added necessary errata patches (also posted on lists, all merged into 4.4), took defconfig, adjusted it according to my needs, and this is what i'm running on my board and this is what i'm using for development. If you point me at what i'm doing wrong way, i'll be glad to accept this.
 I'm over.

Kind regards,
Pavel Fedin
Expert Engineer
Samsung Electronics Research center Russia
