From: Adrian Bunk <bunk@kernel.org>
Subject: 2.6.23-rc4-mm1 net bitops compile error
Date: Sun, 2 Sep 2007 11:14:17 +0200
Message-ID: <20070902091416.GJ16016@stusta.de>
References: <20070831215822.26e1432b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	Jiri Slaby <jirislaby@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:42853 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754001AbXIBJOP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Sep 2007 05:14:15 -0400
Content-Disposition: inline
In-Reply-To: <20070831215822.26e1432b.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

defconfig fails with the following error on parisc:

<--  snip  -->

...
  CC      net/core/gen_estimator.o
In file included from include2/asm/bitops.h:111,
                 from /home/bunk/linux/kernel-2.6/linux-2.6.23-rc4-mm1/net/core/gen_estimator.c:18:
/home/bunk/linux/kernel-2.6/linux-2.6.23-rc4-mm1/include/asm-generic/bitops/non-atomic.h: 
In function '__set_bit':
/home/bunk/linux/kernel-2.6/linux-2.6.23-rc4-mm1/include/asm-generic/bitops/non-atomic.h:17: 
error: implicit declaration of function 'BIT_MASK'
/home/bunk/linux/kernel-2.6/linux-2.6.23-rc4-mm1/include/asm-generic/bitops/non-atomic.h:18: 
error: implicit declaration of function 'BIT_WORD'
make[3]: *** [net/core/gen_estimator.o] Error 1

<--  snip  -->

Either #include <asm/bitops.h> must become forbidden and #error or the 
move of the #define's to include/linux/bitops.h reverted.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

