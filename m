From: Yanfei Wang <backyes@mail.ustc.edu.cn>
Subject: Re: [Doubt on Implict BUGs caused LRO] doubt about lro status in
 v3.12 of torvalds/linux.git
Date: Sat, 23 Nov 2013 11:16:05 +0800
Message-ID: <CAJULongu0OA0wsvnzoJQwSDR1OsE5MYz3Skn7_H0ti-azSTPTg@mail.gmail.com>
References: <CAJULonje7V_sMt6joBBsM3uuQkYFhfNK70BXzN0EyS3sQNb0uQ@mail.gmail.com>
	<1385137972.10637.86.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>,
	China Kernel <kernel@vger.linux-kernel.cn>,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1385137972.10637.86.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eric,

Thanks for quick reply.  :-)

Also, I am confused that in v3.12 why inet_lro.c file is not found in
/net/ipv4/ directory, while Makefile has "obj-$(CONFIG_INET_LRO) +=
inet_lro.o" and LRO heads file exsits.

If I am wrong, pls correct me, :-)

 See the steps 3 for details,(I have repeated it for several times)
----
3. cd net/ipv4,
 [backyes@f14 ipv4]$ cat Makefile | grep lro
obj-$(CONFIG_INET_LRO) += inet_lro.o
[backyes@f14 ipv4]$ ls inet_*
inet_connection_sock.c  inet_diag.c  inet_fragment.c
inet_hashtables.c  inet_timewait_sock.c
---

Best regards

Yanfei Wang




On Sat, Nov 23, 2013 at 12:32 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2013-11-22 at 23:00 +0800, Yanfei Wang wrote:
>> Hi,
>>
>> Compared to the earlier kernel version, I found that Large receive
>> offload(LRO) is obsolete in latest kernel, and that is verified from
>> other materials about Generic receive offload(GRO).
>>
>> However,  I also found some LRO header files and  lro-related
>> functions referred by some drivers, and the lro-related function
>> definition is already removed at the same time!
>>
>> TEST steps:
>> 1. my git local db config as follow, url =
>> http://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
>> 2. git checkout v3.12 -b 3.12
>> 3. cd net/ipv4,
>>  [backyes@f14 ipv4]$ cat Makefile | grep lro
>> obj-$(CONFIG_INET_LRO) += inet_lro.o
>> [backyes@f14 ipv4]$ ls inet_*
>> inet_connection_sock.c  inet_diag.c  inet_fragment.c
>> inet_hashtables.c  inet_timewait_sock.c
>> [backyes@f14 ipv4]$
>> Here, Makefile has inet_lro.o config, while the inet_lro.c is removed.
>> 4. lro functions referred by some drivers, as follow,
>> [backyes@f14 linux]$ grep "inet_lro" * -r
>> drivers/net/ethernet/pasemi/pasemi_mac.c:#include <linux/inet_lro.h>
>> drivers/net/ethernet/pasemi/pasemi_mac_ethtool.c:#include <linux/inet_lro.h>
>> drivers/infiniband/hw/nes/nes_hw.c:#include <linux/inet_lro.h>
>> drivers/infiniband/hw/nes/nes_hw.h:#include <linux/inet_lro.h>
>> include/linux/inet_lro.h: *  linux/include/linux/inet_lro.h
>> net/ipv4/Makefile:obj-$(CONFIG_INET_LRO) += inet_lro.o
>>
>> so, I understand that the removal of LRO is not clean, which will
>> cause compiler error for some kernel config.
>>
>
> I think you are slightly confused.
>
> LRO is not yet removed.
>
> Feel free to contribute ;)
>
> As long as at least one driver still uses LRO, we can not remove LRO.
>
> Converting a driver means testing the new driver, and owning the
> hardware.
>
>
>
