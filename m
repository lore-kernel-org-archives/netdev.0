From: Baozeng Ding <sploving1@gmail.com>
Subject: Re: net/sctp: BUG: KASAN: stack-out-of-bounds in memcmp
Date: Sat, 12 Nov 2016 18:12:27 +0800
Message-ID: <57cbb177-3e1a-0f27-062b-597db8232888@gmail.com>
References: <6843fbba-a11c-8bc4-495a-294dc7fdcc35@gmail.com>
 <CADvbK_emewigJ3pcxy5W4h5UdcA1LtTmFz4Zkqtit6An9OaYpg@mail.gmail.com>
 <cd16b62f-228a-e3de-f68e-6db39e97da0b@gmail.com>
 <CADvbK_ebJHcvvBFcnn0sfhabPe20BTB3A5ny95MZq_uN4MibTw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Vladislav Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        David Miller <davem@davemloft.net>, linux-sctp@vger.kernel.org,
        network dev <netdev@vger.kernel.org>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:33880 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938318AbcKLKNi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 12 Nov 2016 05:13:38 -0500
In-Reply-To: <CADvbK_ebJHcvvBFcnn0sfhabPe20BTB3A5ny95MZq_uN4MibTw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2016/11/10 13:48, Xin Long wrote:
> On Sat, Oct 15, 2016 at 4:28 PM, Baozeng Ding <sploving1@gmail.com> wrote:
>> Hello Xin Long,
>>
>> On 2016/10/14 19:13, Xin Long wrote:
>>> On Sat, Aug 20, 2016 at 3:51 PM, Baozeng Ding <sploving1@gmail.com> wrote:
>>>> Hello all,
>>>> The following program triggers  stack-out-of-bounds in memcmp. The kernel version is 4.8.0-rc1+ (on Aug 13 commit 118253a593bd1c57de2d1193df1ccffe1abe745b). Thanks.
>>> ...
>>>>
>>>> #define _GNU_SOURCE
>>>> #include <unistd.h>
>>>> #include <stdint.h>
>>>> #include <sys/socket.h>
>>>> #include <sys/mman.h>
>>>> #include <linux/in.h>
>>>> #include <fcntl.h>
>>>> #include <string.h>
>>>> #include <stdio.h>
>>>>
>>>> int main()
>>>> {
>>>>         int fd;
>>>>         mmap((void *)0x20000000ul, 0xff2000ul, 0x3ul, 0x32ul, -1, 0x0ul);
>>>>         fd = socket(AF_INET6, SOCK_STREAM, IPPROTO_SCTP);
>>>>         memcpy((void*)0x20f82f80, "\x0a\x00\xab\x12\x72\xd4\x19\x9a\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x85\xda\x00\xa0\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00", 128);
>>>>         bind(fd, (struct sockaddr*)0x20f82f80ul, 0x80ul);
>>>>         *(uint64_t*)0x202e1fc8 = (uint64_t)0x20f77f80;
>>>>         *(uint32_t*)0x202e1fd0 = (uint32_t)0x80;
>>>>         *(uint64_t*)0x202e1fd8 = (uint64_t)0x20f7dfe0;
>>>>         *(uint64_t*)0x202e1fe0 = (uint64_t)0x2;
>>>>         *(uint64_t*)0x202e1fe8 = (uint64_t)0x20f77000;
>>>>         *(uint64_t*)0x202e1ff0 = (uint64_t)0x3;
>>>>         *(uint32_t*)0x202e1ff8 = (uint32_t)0x80;
>>>>         memcpy((void*)0x20f77f80, "\x0a\x00\xab\x12\xb0\xb3\x20\x7b\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\xc2\xc2\x0b\xb2\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00", 128);
>>>>         *(uint64_t*)0x20f7dfe0 = (uint64_t)0x20f77fc5;
>>>>         *(uint64_t*)0x20f7dfe8 = (uint64_t)0x3b;
>>>>         *(uint64_t*)0x20f7dff0 = (uint64_t)0x20f77fac;
>>>>         *(uint64_t*)0x20f7dff8 = (uint64_t)0x54;
>>>>         memcpy((void*)0x20f77fc5, "\xa5\x7d\xf3\xc4\xfe\xd3\xfd\x44\x63\x00\x8c\x1e\x4c\x2e\x8d\x8d\x9a\x9c\x9c\x9d\x5b\x7c\xe1\x06\xf7\x15\x16\xed\x68\xd1\xfc\xf4\xa4\x3a\xe4\x69\x51\x16\x74\xf4\x1a\xcf\x0e\x99\xc3\xa3\x87\xe7\x81\x6c\x10\x78\x75\x17\x69\x9d\x11\x0c\xc7", 59);
>>>>         memcpy((void*)0x20f77fac, "\x86\x08\x89\x3c\xf3\x58\xea\xe7\x64\x6a\xfb\xb5\xe8\xdd\x5f\x69\xa5\xd4\xdc\xd9\xe7\x71\x95\x07\x78\x7b\x21\xda\x43\x9c\x62\x4d\xca\x64\xb5\x6e\x96\x55\xe9\x58\x76\x66\x1d\xb9\x7b\xe6\x20\xc1\xa9\xed\x70\xc1\x2b\x7c\x86\x8c\xba\x28\xb3\x2c\xb9\x64\xb7\x84\x65\x0d\x7f\xa6\x98\x6f\x49\xcb\x35\xad\x5a\xdf\x13\x75\x99\x57\x7e\xbb\x38\x89", 84);
>>>>         *(uint64_t*)0x20f77000 = (uint64_t)0x15;
>>>>         *(uint32_t*)0x20f77008 = (uint32_t)0x1;
>>>>         *(uint32_t*)0x20f7700c = (uint32_t)0xfffffffffffffffe;
>>>>         *(uint8_t*)0x20f77010 = (uint8_t)0xbb;
>>>>         *(uint8_t*)0x20f77011 = (uint8_t)0x2;
>>>>         *(uint8_t*)0x20f77012 = (uint8_t)0x5;
>>>>         *(uint8_t*)0x20f77013 = (uint8_t)0x2;
>>>>         *(uint8_t*)0x20f77014 = (uint8_t)0x80000000;
>>>>         *(uint64_t*)0x20f77015 = (uint64_t)0x10;
>>>>         *(uint32_t*)0x20f7701d = (uint32_t)0xffff;
>>>>         *(uint32_t*)0x20f77021 = (uint32_t)0x1;
>>>>         *(uint64_t*)0x20f77025 = (uint64_t)0x13;
>>>>         *(uint32_t*)0x20f7702d = (uint32_t)0x6;
>>>>         *(uint32_t*)0x20f77031 = (uint32_t)0xfffffffffffffe00;
>>>>         *(uint8_t*)0x20f77035 = (uint8_t)0x80000000;
>>>>         *(uint8_t*)0x20f77036 = (uint8_t)0xfffffffffffffff8;
>>>>         sendmmsg(fd, (struct mmsghdr *)0x202e1fc8ul, 0x1ul, 0x1ul);
>>>>         return 0;
>>>> }
>>>>
>>> Hi, Baozeng, I couldn't reproduce this issue with this script,
>>> even in 118253a593bd1c57de2d1193df1ccffe1abe745b
>>> do I need to do some extra config for this ?
>>>
>> You need config KASAN.
>> CONFIG_HAVE_ARCH_KASAN=y
>> CONFIG_KASAN=y
>> CONFIG_KASAN_INLINE=y
>> CONFIG_KASAN_SHADOW_OFFSET=0xdffffc0000000000
>>
>> I justed tested with b67be92feb486f800d80d72c67fd87b47b79b18e(Octor 12),
>> it sitll exits. If you still cannot reproduce it, i will send the .config to you privately. Thanks.
>>
> 
> Hi Baozeng, sorry for so late. but this issue is always on my radar.
> 
> I still couldnot reproduce it, even on
> b67be92feb486f800d80d72c67fd87b47b79b18e in any of
> git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
> git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
> git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git
> 
> with:
> CONFIG_KASAN_SHADOW_OFFSET=0xdffffc0000000000
> CONFIG_HAVE_ARCH_KASAN=y
> CONFIG_KASAN=y
> # CONFIG_KASAN_OUTLINE is not set
> CONFIG_KASAN_INLINE=y
> # CONFIG_TEST_KASAN is not set
> ...
> attachment is my .config from linux.git
> 
> I also tried with your .config, but in my box, it could only build 105
> .ko instead of 2000+. I don't think it works.
>
I used qemu to run the it:
qemu-system-x86_64 -m 1024 -net nic -net user,host=10.0.2.10,hostfwd=tcp::16059-:22 -display none -serial stdio -no-reboot -enable-kvm -numa node,nodeid=0,cpus=0-1 -numa node,nodeid=1,cpus=2-3 -smp sockets=2,cores=2,threads=1 -usb -usbdevice mouse -usbdevice tablet -soundhw all -hda ./wheezy.img -snapshot -kernel ./bzImage -append console=ttyS0 vsyscall=native rodata=n oops=panic panic_on_warn=1 panic=-1 ftrace_dump_on_oops=orig_cpu earlyprintk=serial slub_debug=UZ root=/dev/sda
> did I miss something ?
> 
