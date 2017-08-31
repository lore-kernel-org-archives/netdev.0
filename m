From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] samples/bpf: Fix compilation issue in redirect
 dummy program
Date: Thu, 31 Aug 2017 13:43:20 +0200
Message-ID: <59A7F658.4020606@iogearbox.net>
References: <1504178199-12410-1-git-send-email-tariqt@mellanox.com> <20170831132710.3b245a6a@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Eran Ben Elisha <eranbe@mellanox.com>, ys114321@gmail.com,
        alexei.starovoitov@gmail.com
To: Jesper Dangaard Brouer <brouer@redhat.com>,
        Tariq Toukan <tariqt@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37874 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750908AbdHaLn3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 07:43:29 -0400
In-Reply-To: <20170831132710.3b245a6a@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/31/2017 01:27 PM, Jesper Dangaard Brouer wrote:
> On Thu, 31 Aug 2017 14:16:39 +0300
> Tariq Toukan <tariqt@mellanox.com> wrote:
>
>> Fix compilation error below:
>>
>> $ make samples/bpf/
>>
>> LLVM ERROR: 'xdp_redirect_dummy' label emitted multiple times to
>> assembly file
>> make[1]: *** [samples/bpf/xdp_redirect_kern.o] Error 1
>> make: *** [samples/bpf/] Error 2
>>
>> Fixes: 306da4e685b4 ("samples/bpf: xdp_redirect load XDP dummy prog on TX device")
>> Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
>> ---
>
> Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>

> What LLVM/clang version do you use?
>
> I don't see this compile error, and I have:
>   $ clang --version
>   clang version 3.9.1 (tags/RELEA

I'm seeing the error as well with a fairly recent LLVM from git
tree (6.0.0git-2d810c2).

Looks like the llvm error is triggered when section name and
the function name for XDP prog is the same. Changing either the
function or the section name right above resolves the issue. If
such error didn't trigger on older versions, people could be
using such naming scheme as done here, so seems to me like a
regression on LLVM side we might need to look at ...

In any case, patch here is fine, thanks!
