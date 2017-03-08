From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH net] bpf: disable broken write protection on i386
Date: Wed, 8 Mar 2017 10:40:14 -0800
Message-ID: <CAGXu5jKkX6bhnFRbM5TmQU3SXrCYi2CJnywcNMsGBBvY+d4gQg@mail.gmail.com>
References: <f722fcb96307fa6c449bbe2f19a4fe9797272678.1488596969.git.daniel@iogearbox.net>
 <CAGXu5jJO=Nwq-ja9+yc==R2d-TAJmMv7eT4v9GYF5v8agqxUnQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Network Development <netdev@vger.kernel.org>,
        Fengguang Wu <fengguang.wu@intel.com>,
        Laura Abbott <labbott@redhat.com>,
        Alexei Starovoitov <ast@kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f52.google.com ([209.85.214.52]:37418 "EHLO
        mail-it0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753795AbdCHSmD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 13:42:03 -0500
Received: by mail-it0-f52.google.com with SMTP id g138so46466169itb.0
        for <netdev@vger.kernel.org>; Wed, 08 Mar 2017 10:40:16 -0800 (PST)
In-Reply-To: <CAGXu5jJO=Nwq-ja9+yc==R2d-TAJmMv7eT4v9GYF5v8agqxUnQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 6, 2017 at 10:11 AM, Kees Cook <keescook@chromium.org> wrote:
> On Fri, Mar 3, 2017 at 7:23 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
>> Latter shows that memory protecting the kernel seems not working either
>> on i386 (!). Test suite output:
>>
>>   [...]
>>   [   12.692836] Write protecting the kernel text: 13416k
>>   [   12.693309] Write protecting the kernel read-only data: 5292k
>>   [   12.693802] rodata_test: test data was not read only
>>   [...]
>>
>> Work-around to not enable ARCH_HAS_SET_MEMORY for i386 is not optimal
>> as it doesn't fix the issue in presumably broken set_memory_*(), but
>> it at least avoids people avoid having to deal with random corruptions
>> that are hard to track down for the time being until a real fix can
>> be found.
>
> Wow. Uhm, so, something must be _really_ broken. i386 should have no
> problem with using the set_memory_*() functions. The fact that
> DEBUG_RODATA_TEST failed is also pretty crazy, but may be unrelated
> (that test was just refactored too).

I'm not able to reproduce this. I built Linus's tree and rodata_test
passes for me on i386. I tried the .config from Fengguang (with
RODATA_TEST=y added), but it still passes for me:
https://lkml.org/lkml/2017/3/1/344

I wonder if something change changed already in the tree? Can you
still reproduce this?

-Kees

-- 
Kees Cook
Pixel Security
