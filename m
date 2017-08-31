From: Y Song <ys114321@gmail.com>
Subject: Re: [PATCH net-next] samples/bpf: Fix compilation issue in redirect
 dummy program
Date: Thu, 31 Aug 2017 08:54:26 -0700
Message-ID: <CAH3MdRVszTVtjruq=-rh26jBtY9evuv7yBz37Ydb8EWSexL+zQ@mail.gmail.com>
References: <1504178199-12410-1-git-send-email-tariqt@mellanox.com>
 <20170831132710.3b245a6a@redhat.com> <59A7F658.4020606@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Eran Ben Elisha <eranbe@mellanox.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f177.google.com ([209.85.217.177]:36659 "EHLO
        mail-ua0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751610AbdHaPzH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 11:55:07 -0400
Received: by mail-ua0-f177.google.com with SMTP id 105so101152uad.3
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 08:55:07 -0700 (PDT)
In-Reply-To: <59A7F658.4020606@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 31, 2017 at 4:43 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 08/31/2017 01:27 PM, Jesper Dangaard Brouer wrote:
>>
>> On Thu, 31 Aug 2017 14:16:39 +0300
>> Tariq Toukan <tariqt@mellanox.com> wrote:
>>
>>> Fix compilation error below:
>>>
>>> $ make samples/bpf/
>>>
>>> LLVM ERROR: 'xdp_redirect_dummy' label emitted multiple times to
>>> assembly file
>>> make[1]: *** [samples/bpf/xdp_redirect_kern.o] Error 1
>>> make: *** [samples/bpf/] Error 2
>>>
>>> Fixes: 306da4e685b4 ("samples/bpf: xdp_redirect load XDP dummy prog on TX
>>> device")
>>> Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
>>> ---
>>
>>
>> Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>
>
>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
>
>> What LLVM/clang version do you use?
>>
>> I don't see this compile error, and I have:
>>   $ clang --version
>>   clang version 3.9.1 (tags/RELEA
>
>
> I'm seeing the error as well with a fairly recent LLVM from git
> tree (6.0.0git-2d810c2).
>
> Looks like the llvm error is triggered when section name and
> the function name for XDP prog is the same. Changing either the
> function or the section name right above resolves the issue. If
> such error didn't trigger on older versions, people could be
> using such naming scheme as done here, so seems to me like a
> regression on LLVM side we might need to look at ...

Martin fixed a similar bug earlier:
=====
commit a2e8bbd2ef5457485f00b6b947bbbfa2778e5b1e
Author: Martin KaFai Lau <kafai@fb.com>
Date:   Thu Jun 8 22:30:17 2017 -0700

    bpf: Fix test_obj_id.c for llvm 5.0

    llvm 5.0 does not like the section name and the function name
    to be the same:
...
=====

gcc also has this behavior. Section name is treated as global
and hence cannot collide with a function name...
