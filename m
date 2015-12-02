From: Christian Zigotzky <chzigotzky@xenosoft.de>
Subject: [P.A. Semi] Does the ethernet interface work on your Electra, Chitra,
 Nemo, and Athena board?
Date: Wed, 2 Dec 2015 05:59:10 +0100
Message-ID: <565E7A9E.4000909@xenosoft.de>
References: <565AF986.9060106@xenosoft.de>
 <CAOJe8K1911vDjMe9m_1vY6DSGpOk0TmL96Qf1whuNFXxHJesGw@mail.gmail.com>
 <565C1B55.4020207@xenosoft.de> <565C8287.7090209@xenosoft.de>
 <20151130181217.GA15921@visitor2.iram.es> <565DB2FE.1010706@xenosoft.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Gabriel Paubert <paubert@iram.es>, netdev@vger.kernel.org,
	Denis Kirjanov <kda@linux-powerpc.org>,
	linuxppc-dev@lists.ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.219]:19676 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752696AbbLBE7T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 23:59:19 -0500
In-Reply-To: <565DB2FE.1010706@xenosoft.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

We tested some 4.3 kernels on a P.A. Semi reference board. Ultimately, 
ethernet does not work, though on the reference board, the interface is 
detected, gets link, but will not pass any packets/traffic.

Somewhere in the source code of the commit "'powerpc-4.3-1' of 
git://git.kernel.org/pub/scm/linux/kernel/git/powerpc/linux (2015-09-03 
23:41:38 (GMT)" is the problem.

Could you please help us to solve the problem?

Thanks in advance,

Christian Zigotzky

On 01 December 2015 at 3:47 PM, Christian Zigotzky wrote:
> Hi All,
>
> I compiled a lot of kernels for some git bisects and I have a result.
>
> Test log
>
> Kernel 4.3 git from Tue Sep 01, 2015 -> PA Semi Ethernet works
> Kernel 4.3 git from Wed Sep 02, 2015 -> PA Semi Ethernet works
> Kernel 4.3 git from Thu Sep 03, 2015 -> PA Semi Ethernet works
> Kernel 4.3 git from Fri Sep 04, 2015 -> PA Semi Ethernet doesn't work
> Kernel 4.3 git from Sat Sep 05, 2015 -> PA Semi Ethernet doesn't work
> Kernel 4.3 git from Mon Sep 07, 2015 -> PA Semi Ethernet doesn't work
> Kernel 4.3 git from Wed Sep 09, 2015 -> PA Semi Ethernet doesn't work
> Kernel 4.3 git from Fri Sep 11, 2015 -> PA Semi Ethernet doesn't work
> Kernel 4.3 RC1 from Sun Sep 13, 2015 -> PA Semi Ethernet doesn't work
> Kernel 4.3 RC2 from Mon Sep 21, 2015 -> PA Semi Ethernet doesn't work
>
> git clone 
> git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git 
> linux-git
>
> git bisect start
>
> git bisect good ac0e137ab0da80e8fc0db2027598e2f7f82a5a02 2015-09-03 
> 00:07:10 (GMT)
>
> git bisect bad 559ec2f8fd50981821621f52db5e1a8ffcf8d792 2015-09-04 
> 23:54:41 (GMT)
>
> Output:
>
> Bisecting: a merge base must be tested
> [ba30011577330b7e29ecb5916d89c6db9fbc5b3d] clk: s5pv210: add missing 
> call to samsung_clk_of_add_provider()
>
> ---
>
> git bisect good
>
> Output:
>
> Bisecting: 4381 revisions left to test after this (roughly 12 steps)
> [3959df1dfb9538498ec3372a2d390bc7fbdbfac2] Merge branch 
> 'ras-core-for-linus' of 
> git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
>
> ---
>
> git bisect good
>
> Output:
>
> Bisecting: 2561 revisions left to test after this (roughly 11 steps)
> [1e1a4e8f439113b7820bc7150569f685e1cc2b43] Merge tag 'dm-4.3-changes' 
> of git://git.kernel.org/pub/scm/linux/kernel/git/device-mapper/linux-dm
>
> ---
>
> git bisect good
>
> Output:
>
> Bisecting: 1280 revisions left to test after this (roughly 10 steps)
> [94c10f0ea303473884f69edd6bbb0cedcf570105] ah4: Fix error return in 
> ah_input().
>
> ---
>
> git bisect good
>
> Output:
>
> Bisecting: 697 revisions left to test after this (roughly 9 steps)
> [4c92b5bb14226faa16d29a1df5752baf1ff22b53] Merge branch 'pcmcia' of 
> git://ftp.arm.linux.org.uk/~rmk/linux-arm (2015-09-03 23:36:33 (GMT))
>
> ---
>
> git bisect good
>
> Output:
>
> Bisecting: 310 revisions left to test after this (roughly 9 steps)
> [a4fdb2a46f617b8b2cd47acec026ec16532edbc6] Merge tag 'arm64-upstream' 
> of git://git.kernel.org/pub/scm/linux/kernel/git/arm64/linux 
> (2015-09-04 14:18:09 (GMT))
>
> ---
>
> git bisect bad
>
> Output:
>
> Bisecting: 237 revisions left to test after this (roughly 8 steps)
> [2db97045aa40da4312f7321845bc52b136c8603a] Merge branch '4.2-fixes' 
> into mips-for-linux-next (2015-09-03 12:06:33 (GMT))
>
> ---
>
> git bisect good
>
> Output:
>
> Bisecting: 132 revisions left to test after this (roughly 7 steps)
> [d690740f22f6520873f96e66aae7119ec2215755] powerpc/powernv: Enable 
> LEDS support (2015-08-27 10:08:44 (GMT))
>
> ---
>
> git bisect good
>
> Output:
>
> Bisecting: 66 revisions left to test after this (roughly 6 steps)
> [662ba3dbceca3ca284885a464ecb8c936f417003] arm64: mm: add __init 
> section marker to free_initrd_mem (2015-07-27 17:29:18 (GMT))
>
> ---
>
> git bisect good
>
> Output:
>
> Bisecting: 33 revisions left to test after this (roughly 5 steps)
> [259800135c654a098d9f0adfdd3d1f20eef1f231] powerpc/eeh: Fix fenced PHB 
> caused by eeh_slot_error_detail() (2015-08-28 03:26:31 (GMT))
>
> ---
>
> git bisect good
>
> Output:
>
> Bisecting: 16 revisions left to test after this (roughly 4 steps)
> [04b8637be92f284409651088f3856f4290a931d8] arm64: alternatives: ensure 
> secondary CPUs execute ISB after patching (2015-08-04 17:52:09 (GMT))
>
> ---
>
> git bisect good
>
> Output:
>
> Bisecting: 8 revisions left to test after this (roughly 3 steps)
> [8eafeb48022816513abc4f440bdad4c350fe81a3] of/fdt: make memblock 
> maximum physical address arch configurable (2015-08-24 09:23:13 (GMT))
>
> ---
>
> git bisect good
>
> Output:
>
> Bisecting: 4 revisions left to test after this (roughly 2 steps)
> [ff474e8ca8547d09cb82ebab56d4c96f9eea01ce] Merge tag 'powerpc-4.3-1' 
> of git://git.kernel.org/pub/scm/linux/kernel/git/powerpc/linux 
> (2015-09-03 23:41:38 (GMT))
>
> ---
>
> git bisect bad
>
> Output:
>
> Bisecting: 1 revision left to test after this (roughly 1 step)
> [55e07668fbba9466e6a9ef7650718356cda38406] cxl: Fix force unmapping 
> mmaps of contexts allocated through the kernel api (2015-08-30 
> 08:47:26 (GMT))
>
> ---
>
> git bisect good
>
> Output:
>
> Bisecting: 0 revisions left to test after this (roughly 0 steps)
> [390fd5929f52bdfb9dfcc03820041ba556780f4a] cxl: Set up and enable PSL 
> Timebase (2015-08-30 08:56:34 (GMT))
>
> ---
>
> git bisect good
>
> Output:
>
> ff474e8ca8547d09cb82ebab56d4c96f9eea01ce is the first bad commit 
> (Merge tag 'powerpc-4.3-1' of 
> git://git.kernel.org/pub/scm/linux/kernel/git/powerpc/linux 
> (2015-09-03 23:41:38 (GMT))
>
> ---
>
> Cheers,
>
> Christian
>
> On 30 November 2015 7:12 PM, Gabriel Paubert wrote:
>> On Mon, Nov 30, 2015 at 06:08:23PM +0100, Christian Zigotzky wrote:
>>> Hi All,
>>>
>>> I have tested the PA Semi Ethernet with the kernels 4.2.3 and 4.3.0
>>> today. With the kernel 4.2.3 it works but with the kernel 4.3.0
>>> final it doesn't work.
>>>
>>> After that I tested some git kernels and release candidates of 4.3.
>>>
>>> Kernel 4.3 git from Tue Sep 01, 2015 -> PA Semi Ethernet works
>>> Kernel 4.3 git from Wed Sep 02, 2015 -> PA Semi Ethernet works
>>> Kernel 4.3 git from Thu Sep 03, 2015 -> PA Semi Ethernet works
>>> Kernel 4.3 git from Fri Sep 04, 2015 -> PA Semi Ethernet doesn't
>>> work (Merge tag 'powerpc-4.3-1': 
>>> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=ff474e8ca8547d09cb82ebab56d4c96f9eea01ce)
>>> Kernel 4.3 git from Sat Sep 05, 2015 -> PA Semi Ethernet doesn't work
>>> Kernel 4.3 git from Mon Sep 07, 2015 -> PA Semi Ethernet doesn't work
>>> Kernel 4.3 git from Wed Sep 09, 2015 -> PA Semi Ethernet doesn't work
>>> Kernel 4.3 git from Fri Sep 11, 2015 -> PA Semi Ethernet doesn't work
>>> Kernel 4.3 RC1 from Sun Sep 13, 2015 -> PA Semi Ethernet doesn't work
>>> Kernel 4.3 RC2 from Mon Sep 21, 2015 -> PA Semi Ethernet doesn't work
>>>
>>> The problematic commit must be between Thu Sep 03, 2015 at 09:37 AM
>>> (UTC +2) and Fri Sep 04, 2015 at 7:38 PM (UTC +2) in the linux git.
>>>
>>> Linux git: Between 
>>> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/log/?ofs=15500
>>> and 
>>> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/log/?ofs=15200.
>>>
>>> Maybe 
>>> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=ff474e8ca8547d09cb82ebab56d4c96f9eea01ce.
>> Unless I miss something, that's the kind of regression that "git 
>> bisect" is
>> designed to find.
>>
>>      Cheers,
>>      Gabriel
>> _______________________________________________
>> Linuxppc-dev mailing list
>> Linuxppc-dev@lists.ozlabs.org
>> https://lists.ozlabs.org/listinfo/linuxppc-dev
>
> _______________________________________________
> Linuxppc-dev mailing list
> Linuxppc-dev@lists.ozlabs.org
> https://lists.ozlabs.org/listinfo/linuxppc-dev
