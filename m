From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] bpf: fix loading of BPF_MAXINSNS sized programs
Date: Wed, 07 Dec 2016 10:53:21 +0100
Message-ID: <5847DC11.1040805@iogearbox.net>
References: <7aad2a49d7a717fd018b338bb9d7167bafd1fdb8.1481069166.git.daniel@iogearbox.net> <7039f9c2-c1d8-7549-7448-e369875ad9c1@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33529 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752618AbcLGJxZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 04:53:25 -0500
In-Reply-To: <7039f9c2-c1d8-7549-7448-e369875ad9c1@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/07/2016 10:42 AM, Sergei Shtylyov wrote:
> Hello!
>
> On 12/7/2016 3:15 AM, Daniel Borkmann wrote:
>
>> General assumption is that single program can hold up to BPF_MAXINSNS,
>> that is, 4096 number of instructions. It is the case with cBPF and
>
>     Up to BPF_MAXINSNS (that is 4096) instructions.

Thanks for nitpicking, I think it's just fine as-is.

>> that limit was carried over to eBPF. When recently testing digest, I
>> noticed that it's actually not possible to feed 4096 instructions
>> via bpf(2).
>>
>> The check for > BPF_MAXINSNS was added back then to bpf_check() in
>> cbd357008604 ("bpf: verifier (add ability to receive verification log)").
>> However, 09756af46893 ("bpf: expand BPF syscall with program load/unload")
>> added yet another check that comes before that into bpf_prog_load(),
>> but this time bails out already in case of >= BPF_MAXINSNS.
>>
>> Fix it up and perform the check early in bpf_prog_load(), so we can drop
>> the second one in bpf_check(). It makes sense, because also a 0 insn
>> program is useless and we don't want to waste any resources doing work
>> up to bpf_check() point. The existing bpf(2) man page documents E2BIG
>> as the official error for such cases, so just stick with it as well.
>>
>> Fixes: 09756af46893 ("bpf: expand BPF syscall with program load/unload")
>> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
>> Acked-by: Alexei Starovoitov <ast@kernel.org>
> [...]
>
> MBR, Sergei
