From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] ppc: bpf_jit: support MOD operation
Date: Wed, 04 Sep 2013 09:04:04 +0200
Message-ID: <5226DB64.3020207@redhat.com>
References: <1377643792-10327-1-git-send-email-murzin.v@gmail.com> <20130902174842.GA1866@hp530> <1378154750.3978.43.camel@pasglop> <20130903195819.GA1971@hp530> <52264C0D.3000409@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	linuxppc-dev@lists.ozlabs.org, paulus@samba.org,
	davem@davemloft.net, Matt Evans <matt@ozlabs.org>,
	netdev <netdev@vger.kernel.org>
To: Vladimir Murzin <murzin.v@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23232 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755775Ab3IDHET (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Sep 2013 03:04:19 -0400
In-Reply-To: <52264C0D.3000409@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/03/2013 10:52 PM, Daniel Borkmann wrote:
> On 09/03/2013 09:58 PM, Vladimir Murzin wrote:
[...]
>>> Do you have a test case/suite by any chance ?
>>>
>>> Ben.
>>>
>>
>> Hi Ben!
>>
>> Thanks for your feedback.
>>
>> This patch is only compile tested. I have no real hardware, but I'll
>> probably bring up qemu ppc64 till end of the week...
>> Meanwhile, I've made simple how-to for testing. You can use it if you wish.
>> It is mainly based on the [1] and rechecked on x86-64.
>
> Please also cc netdev on BPF related changes.
>
> Actually, your test plan can be further simplified ...
>
> For retrieving and disassembling the JIT image, we have bpf_jit_disasm [1].
>
>   1) echo 2 > /proc/sys/net/core/bpf_jit_enable
>   2) ... attach filter ...
>   3) bpf_jit_disasm -o
>
> For generating a simple stupid test filter, you can use bpfc [2] (also
> see its man page). E.g. ...
>
>    # cat blub
>    ldi #10
>    mod #8
>    ret a
>    # bpfc blub
>    { 0x0, 0, 0, 0x0000000a },
>    { 0x94, 0, 0, 0x00000008 },
>    { 0x16, 0, 0, 0x00000000 },

Plus something like ...

ldxi #0
mod x
ret a

For longer-term testing, also trinity has BPF support. ;)

> And load this array e.g. either into a small C program that attaches this
> as BPF filter, or simply do bpfc blub > blub2 and run netsniff-ng -f blub2\
> -s -i eth0, that should also do it.
>
> Then, when attached, the kernel should truncate incoming frames for pf_packet
> into max length of 2, just as an example.
>
>    [1] kernel tree, tools/net/bpf_jit_disasm.c
>    [2] git clone git://github.com/borkmann/netsniff-ng.git
