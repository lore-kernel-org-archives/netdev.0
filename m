From: William Tu <u9012063@gmail.com>
Subject: Re: Assertion faileda at samples/bpf/test_maps
Date: Wed, 5 Oct 2016 09:48:52 +0900
Message-ID: <CALDO+SYAxzzOTQu-Pgi6uPke0ojU46iS+0vk6cm5diytWca=EQ@mail.gmail.com>
References: <CAEQ0BR4j65Upa_ZLo6yC1khOprvXx1_iVxCKuSxbn+Df1mo_OQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Louie Lu <louie.lu@hopebaytech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f49.google.com ([209.85.214.49]:38812 "EHLO
        mail-it0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751722AbcJEAtd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2016 20:49:33 -0400
Received: by mail-it0-f49.google.com with SMTP id o19so144974071ito.1
        for <netdev@vger.kernel.org>; Tue, 04 Oct 2016 17:49:33 -0700 (PDT)
In-Reply-To: <CAEQ0BR4j65Upa_ZLo6yC1khOprvXx1_iVxCKuSxbn+Df1mo_OQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Louie,

Can you check whether your num_possible_cpu == num_online_cpu?
by doing:
cat /sys/devices/system/cpu/possible
and see how many cpu[0-9]
ls /sys/devices/system/cpu/cpu*

There is a related discussion here:
https://www.mail-archive.com/netdev@vger.kernel.org/msg121258.html

Regards,
William

On Sun, Oct 2, 2016 at 3:55 PM, Louie Lu <louie.lu@hopebaytech.com> wrote:
> Hi everyone,
>
> I'm now playing net-next samples/bpf things, and I found that
> test_maps will give an assertion
>
> ```
> test_maps: /home/grd/linux/net-next/samples/bpf/test_maps.c:146:
> test_percpu_hashmap_sanity: Assertion `bpf_lookup_elem(map_fd, &key,
> value) == -1 && errno == ENOENT' failed.
> [1]    20706 abort (core dumped)  ./test_maps
> ```
>
> I've done the check at [[iovisor-dev] Assertion fails at
> samples/bpf/test_maps](http://lists.iovisor.org/pipermail/iovisor-dev/2016-June/000281.html)
> which tells me to set ulimit to unlimited or patching by setrlimit().
>
> The problem is bpf_lookup_elem return -1, and errno return 0.
>
> I'm using Intel(R) Core(TM) i7-2640M and net-next commit:
> 803783849fed11, 4.8.0-rc7-ARCH-02283-g8037838.
>
> And, a strange this is when I done this at QEMU, test_maps perform
> will and pass the test.
>
> Is that my hardware problem or something else?
>
>
> Thanks.
>
> Louie Lu.
