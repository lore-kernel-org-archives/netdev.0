From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] bpf: disable broken write protection on i386
Date: Wed, 08 Mar 2017 22:21:00 +0100
Message-ID: <58C075BC.8050004@iogearbox.net>
References: <f722fcb96307fa6c449bbe2f19a4fe9797272678.1488596969.git.daniel@iogearbox.net> <CAGXu5jJO=Nwq-ja9+yc==R2d-TAJmMv7eT4v9GYF5v8agqxUnQ@mail.gmail.com> <CAGXu5jKkX6bhnFRbM5TmQU3SXrCYi2CJnywcNMsGBBvY+d4gQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Network Development <netdev@vger.kernel.org>,
        Fengguang Wu <fengguang.wu@intel.com>,
        Laura Abbott <labbott@redhat.com>,
        Alexei Starovoitov <ast@kernel.org>
To: Kees Cook <keescook@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:55555 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932069AbdCHVVF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 16:21:05 -0500
In-Reply-To: <CAGXu5jKkX6bhnFRbM5TmQU3SXrCYi2CJnywcNMsGBBvY+d4gQg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/08/2017 07:40 PM, Kees Cook wrote:
> On Mon, Mar 6, 2017 at 10:11 AM, Kees Cook <keescook@chromium.org> wrote:
>> On Fri, Mar 3, 2017 at 7:23 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
>>> Latter shows that memory protecting the kernel seems not working either
>>> on i386 (!). Test suite output:
>>>
>>>    [...]
>>>    [   12.692836] Write protecting the kernel text: 13416k
>>>    [   12.693309] Write protecting the kernel read-only data: 5292k
>>>    [   12.693802] rodata_test: test data was not read only
>>>    [...]
>>>
>>> Work-around to not enable ARCH_HAS_SET_MEMORY for i386 is not optimal
>>> as it doesn't fix the issue in presumably broken set_memory_*(), but
>>> it at least avoids people avoid having to deal with random corruptions
>>> that are hard to track down for the time being until a real fix can
>>> be found.
>>
>> Wow. Uhm, so, something must be _really_ broken. i386 should have no
>> problem with using the set_memory_*() functions. The fact that
>> DEBUG_RODATA_TEST failed is also pretty crazy, but may be unrelated
>> (that test was just refactored too).
>
> I'm not able to reproduce this. I built Linus's tree and rodata_test
> passes for me on i386. I tried the .config from Fengguang (with
> RODATA_TEST=y added), but it still passes for me:
> https://lkml.org/lkml/2017/3/1/344
>
> I wonder if something change changed already in the tree? Can you
> still reproduce this?

I'll answer in a bit an will move the discussion over to the other
thread on the same topic ("[net/bpf] 3051bf36c2 BUG: unable to handle
kernel paging request at 0000a7cf" [1]) with you, Laura and Dave in
Cc as well.

   [1] https://lkml.org/lkml/2017/3/8/620
