From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: [PATCH] Force UNIX domain sockets to be built in
Date: Mon, 31 Dec 2007 16:34:55 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0712311628330.28123@fbirervta.pbzchgretzou.qr>
References: <alpine.LSU.0.999.0712311300020.3686@be1.lrz>
 <20071231122419.GA13803@does.not.exist> <alpine.LSU.0.999.0712311335210.3761@be1.lrz>
 <20071231144255.GB13803@does.not.exist> <alpine.LSU.0.999.0712311553530.4211@be1.lrz>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Adrian Bunk <bunk@kernel.org>, devzero@web.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Bodo Eggert <7eggert@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:38664 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751332AbXLaPe4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 10:34:56 -0500
In-Reply-To: <alpine.LSU.0.999.0712311553530.4211@be1.lrz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Dec 31 2007 16:19, Bodo Eggert wrote:
>Adrian Bunk wrote:
>> 
>> The only advantage I see is that the kernel image you have to flash 
>> can be made smaller - with the disadvantage that the running kernel
>> is bigger by more than 10%.
>> 
>> If you don't believe me, try it yourself:
>> Build all drivers statically into your kernel, and then compare the 
>> vmlinux sizes with CONFIG_MODULES=n and CONFIG_MODULES=y.
>
>If you'd aim for a small kernel image, you would build anything as a module 
>that is not requred for booting.
>
Yes, there is a tradeoff for both.

Example:
16:30 ichi:../net/802 > l fc.o fc.ko 
-rw-r--r-- 1 jengelh users 7961 Dec 27 15:19 fc.ko
-rw-r--r-- 1 jengelh users 2453 Dec 28 23:58 fc.o
(from a recent not-so-complete patch turning CONFIG_FC etc. into =m)

If fc was modular, it might save the 2453 bytes off the core kernel image,
but adds ~5508 bytes to disk.
So one has to pick =y or =m depending on whatever suits his/her situation.

But the choice should be _available_.

>>>> After all, changing it to a bool will allow us to make the
>>>> kernel image for nearly everyone smaller by a few hundred
>>>> bytes...
>>> 
>>> I can't see why optionally building it as a module would force us
>>> to make the kernel bigger. It may be a little more ugly to
>>> support =m, but thats it, isn't it?
>> 
>> On architectures like x86 where __exit code is freed at runtime 
>> af_unix_exit() makes your kernel image (but not the running kernel) 
>> bigger.
>> 
>> With CONFIG_MODULES=y the 13 EXPORT_SYMBOL's that only exist for
>> the theoretical possibility of CONIG_UNIX=m waste a few hundred
>> bytes of memory.
